#!/bin/bash

# Script para configurar debugging por WiFi automáticamente

echo "📡 Configurando debugging por WiFi..."

# Verificar si hay dispositivos USB conectados
usb_devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | grep -v ":5555" | wc -l)

if [ $usb_devices -eq 0 ]; then
    echo "❌ No hay dispositivos USB conectados"
    echo "📱 Conecta tu dispositivo por USB primero para configurar WiFi debugging"
    exit 1
fi

echo "✅ Dispositivo USB detectado"

# Habilitar TCP/IP debugging en puerto 5555
echo "🔧 Habilitando TCP/IP debugging..."
adb tcpip 5555

sleep 2

# Obtener IP del dispositivo
echo "🔍 Obteniendo IP del dispositivo..."
device_ip=$(adb shell ip route | grep wlan0 | grep -E 'src [0-9.]+' | head -1 | sed 's/.*src \([0-9.]*\).*/\1/')

if [ -z "$device_ip" ]; then
    echo "❌ No se pudo obtener la IP del dispositivo"
    echo "📱 Verifica que el dispositivo esté conectado a WiFi"
    exit 1
fi

echo "📱 IP del dispositivo: $device_ip"

# Desconectar USB y conectar por WiFi
echo "🔗 Conectando por WiFi..."
adb disconnect > /dev/null 2>&1
sleep 1
adb connect $device_ip:5555

# Verificar conexión
sleep 2
if adb devices | grep -q "$device_ip:5555"; then
    echo "✅ Dispositivo conectado por WiFi: $device_ip:5555"

    # Guardar IP para uso futuro
    echo "$device_ip" > .device_ip
    echo "💾 IP guardada en .device_ip"

    echo ""
    echo "🎉 ¡Configuración completada!"
    echo "📱 Ahora puedes desconectar el cable USB"
    echo "🚀 Usa: ./run_on_any_device.sh para ejecutar la app"

else
    echo "❌ No se pudo conectar por WiFi"
    echo "🔄 Intenta ejecutar el script nuevamente"
fi