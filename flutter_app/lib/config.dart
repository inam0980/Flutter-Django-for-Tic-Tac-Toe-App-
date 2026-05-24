/// App-wide configuration constants.
///
/// IMPORTANT: when running on the Android emulator, `localhost` on your
/// PC is reached as `10.0.2.2`. On a physical phone over WiFi, use your
/// PC's LAN IP (e.g. 192.168.1.x). In production, set this to your
/// deployed URL.
class AppConfig {
  /// HTTP base URL for REST APIs.
  /// 10.0.2.2 = Android emulator's alias for host machine.
  /// 192.168.1.105 = dev laptop's LAN IP (for physical phone on same WiFi).
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE', defaultValue: 'http://192.168.1.105:8000');

  /// WebSocket base URL. Same host as API, just ws:// / wss://.
  static const String wsBaseUrl =
      String.fromEnvironment('WS_BASE', defaultValue: 'ws://192.168.1.105:8000');

  static const String appName = 'inamtactoe';
}
