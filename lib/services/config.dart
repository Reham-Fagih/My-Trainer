import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads BASE_URL from the environment (.env) when available. If dotenv
/// isn't initialized or the value is missing, falls back to the Android
/// emulator host mapping which points to the host machine: 10.0.2.2:5000.
String get baseUrl {
  if (dotenv.isInitialized) {
    final env = dotenv.env['BASE_URL'];
    if (env != null && env.isNotEmpty) return env;
  }

  // Emulator default
  return 'http://10.0.2.2:5000';
}
