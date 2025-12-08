import 'package:flutter/foundation.dart';

class AppConfig {
  // URL untuk Production (Website asli)
  static const String _prodUrl =
      'https://farrel-arrayyan-mount-track.pbp.cs.ui.ac.id';

  // URL untuk Development (Localhost)
  static const String _devUrl = 'http://localhost:8000';

  // Logika otomatis:
  // Jika kReleaseMode (aplikasi di-build untuk rilis), pakai URL Prod.
  // Jika tidak (sedang debug/run biasa), pakai URL Dev.
  static const String baseUrl = kReleaseMode ? _prodUrl : _devUrl;
}
