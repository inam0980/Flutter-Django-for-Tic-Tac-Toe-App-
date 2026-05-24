/// App-wide configuration constants.
///
/// IMPORTANT: when running on the Android emulator, `localhost` on your
/// PC is reached as `10.0.2.2`. On a physical phone over WiFi, use your
/// PC's LAN IP (e.g. 192.168.1.x). In production, set this to your
/// deployed URL.
class AppConfig {
  /// HTTP base URL for REST APIs.
  /// Default: production Render deployment (works on any network).
  /// Override at build time for local dev:
  ///   flutter run --dart-define=API_BASE=http://10.0.2.2:8000 \
  ///              --dart-define=WS_BASE=ws://10.0.2.2:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://tictactoe-backend-729l.onrender.com',
  );

  /// WebSocket base URL. Same host as API, just ws:// / wss://.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE',
    defaultValue: 'wss://tictactoe-backend-729l.onrender.com',
  );

  static const String appName = 'inamtactoe';
}
