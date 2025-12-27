/// Development configuration
///
/// This file contains development-specific settings that you can modify
/// without changing the main environment configuration.
class DevConfig {
  // Private constructor
  DevConfig._();

  /// Your development machine's IP address
  ///
  /// To find your IP address:
  ///
  /// **Windows:**
  /// - Open Command Prompt and run: `ipconfig`
  /// - Look for "IPv4 Address" under your network adapter
  ///
  /// **macOS/Linux:**
  /// - Open Terminal and run: `ifconfig` or `ip addr show`
  /// - Look for your network interface (usually eth0, wlan0, or en0)
  ///
  /// **Common IP ranges:**
  /// - 192.168.1.xxx (most home routers)
  /// - 192.168.0.xxx (some home routers)
  /// - 10.0.0.xxx (some corporate networks)
  /// - 172.16.0.xxx to 172.31.0.xxx (some networks)
  ///
  /// **Special cases:**
  /// - Android Emulator: use '10.0.2.2' to reach host machine
  /// - iOS Simulator: use 'localhost' or '127.0.0.1'
  static const String developmentServerIp = '192.168.1.6';

  /// Alternative IPs to try if the main one doesn't work
  static const List<String> alternativeIps = [
    '192.168.1.6', // Current detected IP
    '192.168.1.100', // Common development IP
    '192.168.0.6', // Same IP on different subnet
    '192.168.0.100', // Common development IP
    '10.0.2.2', // Android emulator host
    'localhost', // Fallback for emulators
  ];

  /// Get the best IP for the current platform
  static String getBestServerIp() {
    // You can implement logic here to test connectivity
    // For now, just return the main development IP
    return developmentServerIp;
  }
}
