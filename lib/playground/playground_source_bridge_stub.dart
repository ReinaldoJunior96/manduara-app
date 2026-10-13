class PlatformSaveResult {
  const PlatformSaveResult({required this.saved, required this.message});

  final bool saved;
  final String message;
}

Future<String?> loadPlaygroundSource() async => null;

Future<PlatformSaveResult> savePlaygroundSource(String source) async =>
    const PlatformSaveResult(
      saved: false,
      message: 'A gravação local está disponível apenas no Flutter Web.',
    );
