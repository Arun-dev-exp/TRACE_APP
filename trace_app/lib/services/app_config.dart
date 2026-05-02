/// Central config — change the base URL here when ngrok restarts or moving to prod.
/// Do NOT scatter this string across the codebase.
class AppConfig {
  AppConfig._();

  /// Local dev backend. Replace with your ngrok URL for device testing.
  /// Example: 'https://abc123.ngrok-free.app'
  static const String baseUrl = 'http://127.0.0.1:3001';
  // Note: 127.0.0.1 works on physical devices ONLY because we ran `adb reverse tcp:3001 tcp:3001`
  // This tunnels the phone's port 3001 over USB directly to the PC's port 3001, bypassing Windows Firewall!
}
