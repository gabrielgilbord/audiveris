#!/bin/bash

# Script para corregir permisos de archivos ejecutables
echo "🔧 Corrigiendo permisos de archivos ejecutables..."

# Corregir permisos de todos los scripts en el directorio principal
chmod +x /app/*.sh 2>/dev/null || true

# Corregir permisos específicamente del script de Audiveris
chmod +x /app/audiveris-5.4/run-audiveris-custom.sh 2>/dev/null || true

# Verificar que el script sea ejecutable
if [ -x "/app/audiveris-5.4/run-audiveris-custom.sh" ]; then
    echo "✅ Script run-audiveris-custom.sh es ejecutable"
else
    echo "⚠️ Script run-audiveris-custom.sh NO es ejecutable, aplicando permisos..."
    chmod +x /app/audiveris-5.4/run-audiveris-custom.sh
    if [ -x "/app/audiveris-5.4/run-audiveris-custom.sh" ]; then
        echo "✅ Permisos aplicados correctamente"
    else
        echo "❌ Error aplicando permisos"
        exit 1
    fi
fi

echo "✅ Permisos corregidos correctamente"
