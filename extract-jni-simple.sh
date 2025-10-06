#!/bin/bash

echo "🔍 Extrayendo librerías JNI de JARs existentes..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

echo "📦 Extrayendo de leptonica-1.83.0-1.5.9.jar..."
if [ -f "lib/leptonica-1.83.0-1.5.9.jar" ]; then
    unzip -o -q "lib/leptonica-1.83.0-1.5.9.jar" -d /tmp/javacpp-cache/
    echo "✅ Leptonica extraído"
else
    echo "⚠️ leptonica-1.83.0-1.5.9.jar no encontrado"
fi

echo "📦 Extrayendo de tesseract-5.3.1-1.5.9.jar..."
if [ -f "lib/tesseract-5.3.1-1.5.9.jar" ]; then
    unzip -o -q "lib/tesseract-5.3.1-1.5.9.jar" -d /tmp/javacpp-cache/
    echo "✅ Tesseract extraído"
else
    echo "⚠️ tesseract-5.3.1-1.5.9.jar no encontrado"
fi

echo "🔍 Buscando librerías JNI extraídas..."
find /tmp/javacpp-cache -name "libjni*.so*" | head -10

echo "🔍 Buscando todas las librerías .so..."
find /tmp/javacpp-cache -name "*.so*" | head -10

# Hacer ejecutables las librerías
find /tmp/javacpp-cache -name "*.so*" -exec chmod +x {} \;

echo "📁 Contenido final del cache:"
ls -la /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No se encontraron librerías .so"

echo "✅ Extracción completada"
