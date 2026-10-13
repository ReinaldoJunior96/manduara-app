// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class PlatformSaveResult {
  const PlatformSaveResult({required this.saved, required this.message});

  final bool saved;
  final String message;
}

const _sourceUrl = 'http://127.0.0.1:8787/source';

Future<String?> loadPlaygroundSource() async {
  try {
    final response = await html.HttpRequest.request(_sourceUrl, method: 'GET');
    return response.status == 200 ? response.responseText : null;
  } catch (_) {
    return null;
  }
}

Future<PlatformSaveResult> savePlaygroundSource(String source) async {
  try {
    final response = await html.HttpRequest.request(
      _sourceUrl,
      method: 'POST',
      sendData: source,
      requestHeaders: const {'Content-Type': 'text/plain; charset=utf-8'},
    );
    return PlatformSaveResult(
      saved: response.status == 200,
      message: response.responseText ?? 'Resposta vazia do servidor local.',
    );
  } catch (_) {
    return const PlatformSaveResult(
      saved: false,
      message: 'Servidor local indisponível. Execute o helper em tool/.',
    );
  }
}
