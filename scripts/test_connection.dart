import 'dart:io';

/// Script para probar la conectividad con el servidor
void main() async {
  print('🔧 Probando configuración de red...\n');

  // IP configurada (cambiar si es necesario)
  const serverIp = '192.168.1.6';

  // Mostrar configuración actual
  print('📋 Configuración actual:');
  print('  serverIp: $serverIp');
  print('  Puertos a probar: 9090, 10600, 8081, 10000');
  print('');

  // Probar conectividad a los puertos principales
  final ports = [9090, 10600, 8081, 10000];

  print('🌐 Probando conectividad a $serverIp...\n');

  for (final port in ports) {
    await testConnection(serverIp, port);
  }

  print('\n✅ Prueba de conectividad completada');
  print('💡 Si hay errores, verifica que:');
  print('   1. El servidor esté corriendo');
  print('   2. La IP sea correcta ($serverIp)');
  print('   3. No haya firewall bloqueando los puertos');
  print('   4. Estés en la misma red WiFi');
}

Future<void> testConnection(String host, int port) async {
  try {
    final socket =
        await Socket.connect(host, port, timeout: const Duration(seconds: 3));
    socket.destroy();
    print('✅ Puerto $port: Conectado');
  } catch (e) {
    print('❌ Puerto $port: Error - ${e.toString().split(':').first}');
  }
}
