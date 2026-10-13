import 'dart:convert';
import 'dart:io';

const _host = '127.0.0.1';
const _port = 8787;
const _sourcePath = 'lib/widgets/playground/playground_badge.dart';
const _maxSourceBytes = 512 * 1024;

Future<void> main() async {
  final project = Directory.current;
  final source = File('${project.path}/$_sourcePath');
  if (!source.existsSync()) {
    stderr.writeln('Execute este helper na raiz do projeto Triluma.');
    exitCode = 64;
    return;
  }

  final server = await HttpServer.bind(_host, _port);
  stdout.writeln('Badge Playground helper: http://$_host:$_port');
  stdout.writeln('Arquivo permitido: ${source.path}');
  stdout.writeln('Encerre com Ctrl+C.');

  await for (final request in server) {
    await _handle(request, source);
  }
}

Future<void> _handle(HttpRequest request, File source) async {
  final response = request.response;
  response.headers
    ..set('Access-Control-Allow-Origin', request.headers.value('origin') ?? '*')
    ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type')
    ..set('Access-Control-Allow-Private-Network', 'true')
    ..set('Cache-Control', 'no-store');

  final origin = request.headers.value('origin');
  if (!_isLocalOrigin(origin)) {
    await _close(response, HttpStatus.forbidden, 'Origem não permitida.');
    return;
  }
  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }
  if (request.uri.path != '/source') {
    await _close(response, HttpStatus.notFound, 'Endpoint não encontrado.');
    return;
  }
  if (request.method == 'GET') {
    response.headers.contentType = ContentType.text;
    response.write(await source.readAsString());
    await response.close();
    return;
  }
  if (request.method != 'POST') {
    await _close(
      response,
      HttpStatus.methodNotAllowed,
      'Método não permitido.',
    );
    return;
  }
  if (request.contentLength > _maxSourceBytes) {
    await _close(
      response,
      HttpStatus.requestEntityTooLarge,
      'Código muito grande.',
    );
    return;
  }

  final bytes = <int>[];
  await for (final chunk in request) {
    bytes.addAll(chunk);
    if (bytes.length > _maxSourceBytes) {
      await _close(
        response,
        HttpStatus.requestEntityTooLarge,
        'Código muito grande.',
      );
      return;
    }
  }
  late final String code;
  try {
    code = utf8.decode(bytes);
  } on FormatException {
    await _close(
      response,
      HttpStatus.badRequest,
      'O conteúdo não é UTF-8 válido.',
    );
    return;
  }
  if (!code.contains('class PlaygroundBadge')) {
    await _close(
      response,
      HttpStatus.unprocessableEntity,
      'O arquivo precisa declarar class PlaygroundBadge.',
    );
    return;
  }

  await source.writeAsString(code, flush: true);
  final format = await Process.run(Platform.resolvedExecutable, [
    'format',
    source.path,
  ], workingDirectory: Directory.current.path);
  response.headers.contentType = ContentType.text;
  if (format.exitCode == 0) {
    response.write(
      'Arquivo salvo e formatado. Acione Hot Reload no processo Flutter (tecla r).',
    );
  } else {
    response.write(
      'Arquivo salvo. O formatador encontrou sintaxe inválida; os erros reais aparecerão ao fazer Hot Reload.\n${format.stderr}',
    );
  }
  await response.close();
}

bool _isLocalOrigin(String? origin) {
  if (origin == null) return true;
  final uri = Uri.tryParse(origin);
  return uri != null &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '::1');
}

Future<void> _close(HttpResponse response, int status, String message) async {
  response.statusCode = status;
  response.headers.contentType = ContentType.text;
  response.write(message);
  await response.close();
}
