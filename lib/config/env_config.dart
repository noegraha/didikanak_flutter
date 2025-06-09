import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get dbUrlSimpan =>
      dotenv.env['DB_URL_SIMPAN'] ??
      'https://v0-api-backend.vercel.app/api/simpan-data';
  static String get dbUrlGet =>
      dotenv.env['DB_URL_GET'] ??
      'https://v0-api-backend.vercel.app/api/get-laporan';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
