import 'playground_source_bridge_stub.dart'
    if (dart.library.html) 'playground_source_bridge_web.dart'
    as platform;

class PlaygroundSourceBridge {
  const PlaygroundSourceBridge();

  Future<String?> loadSource() => platform.loadPlaygroundSource();

  Future<PlaygroundSaveResult> saveSource(String source) async {
    final result = await platform.savePlaygroundSource(source);
    return PlaygroundSaveResult(saved: result.saved, message: result.message);
  }
}

class PlaygroundSaveResult {
  const PlaygroundSaveResult({required this.saved, required this.message});

  final bool saved;
  final String message;
}
