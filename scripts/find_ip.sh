#!/bin/bash

echo "🔍 Buscando tu IP de desarrollo..."
echo ""

# Detectar el sistema operativo
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📱 Sistema: Linux"
    IP=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 Sistema: macOS"
    IP=$(route get default | grep interface | awk '{print $2}' | xargs ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "📱 Sistema: Windows"
    echo "Ejecuta este comando en PowerShell:"
    echo "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike '*Loopback*'} | Select-Object IPAddress"
    exit 0
else
    echo "❌ Sistema no reconocido: $OSTYPE"
    exit 1
fi

if [ -n "$IP" ]; then
    echo "✅ IP encontrada: $IP"
    echo ""
    echo "📝 Para configurar tu app:"
    echo "1. Edita lib/config/dev_config.dart"
    echo "2. Cambia developmentServerIp a '$IP'"
    echo ""
    echo "🚀 O ejecuta con variable de entorno:"
    echo "flutter run --dart-define=SERVER_IP=$IP"
else
    echo "❌ No se pudo encontrar la IP automáticamente"
    echo "Ejecuta manualmente:"
    echo "  Linux: ip addr show"
    echo "  macOS: ifconfig"
    echo "  Windows: ipconfig"
fi