#!/bin/bash

echo "🚀 Desplegando servicio Audiveris simplificado..."

# Eliminar scripts complejos que pueden causar problemas
echo "🧹 Limpiando scripts complejos..."
rm -f *.sh
rm -f fly.toml

# Mantener solo los archivos esenciales
echo "📦 Archivos esenciales mantenidos:"
echo "  - index.js (servicio principal)"
echo "  - package.json"
echo "  - Dockerfile"
echo "  - audiveris-5.4/ (directorio de Audiveris)"

# Crear directorios necesarios
echo "📁 Creando directorios necesarios..."
mkdir -p uploads/input
mkdir -p uploads/output

# Verificar que Audiveris esté disponible
if [ -d "audiveris-5.4" ]; then
    echo "✅ Directorio audiveris-5.4 encontrado"
    if [ -f "audiveris-5.4/lib/audiveris.jar" ]; then
        echo "✅ audiveris.jar encontrado"
    else
        echo "❌ audiveris.jar no encontrado"
        exit 1
    fi
else
    echo "❌ Directorio audiveris-5.4 no encontrado"
    exit 1
fi

echo "✅ Servicio listo para despliegue"
echo "📋 Para desplegar:"
echo "   1. Construir imagen: docker build -t audiveris-service ."
echo "   2. Ejecutar contenedor: docker run -p 4000:4000 audiveris-service"
echo "   3. O desplegar en tu plataforma preferida (Render, Railway, etc.)"
