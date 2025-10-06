#!/bin/bash

# Script para ejecutar Audiveris con configuración optimizada
INPUT_FILE="$1"
OUTPUT_DIR="$2"

echo "🚀 Ejecutando Audiveris con configuración optimizada..."
echo "📁 Archivo de entrada: $INPUT_FILE"
echo "📁 Directorio de salida: $OUTPUT_DIR"

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/tmp/javacpp-cache:$LD_LIBRARY_PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64
export JAVACPP_VERBOSE=1

# Crear directorio de cache si no existe
mkdir -p /tmp/javacpp-cache

# Crear enlaces simbólicos para las librerías nativas
echo "🔗 Creando enlaces simbólicos para librerías nativas..."
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/lib/liblept.so 2>/dev/null || echo "⚠️ No se pudo crear enlace para liblept.so"
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/lib/libtesseract.so 2>/dev/null || echo "⚠️ No se pudo crear enlace para libtesseract.so"

# Cambiar al directorio de Audiveris
cd /app/audiveris-5.4

# Precargar librerías JavaCPP para forzar extracción en cache
echo "📥 Precargando librerías JavaCPP (leptonica, tesseract)..."
java \
  -Djavacpp.platform=linux-x86_64 \
  -Djavacpp.cache.dir=/tmp/javacpp-cache \
  -Djavacpp.verbose=true \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache" \
  -cp "lib/*" \
  org.bytedeco.javacpp.Loader \
  -Dloader.preload=org.bytedeco.leptonica.global.leptonica,org.bytedeco.tesseract.global.tesseract || echo "⚠️ Precarga JavaCPP no determinante, continuando..."

echo "🔍 Archivos JNI en cache tras precarga (si existen):"
find /tmp/javacpp-cache -type f -name "libjni*.so*" | head -20 || true

# Ejecutar Audiveris con configuración que usa librerías del sistema y JavaCPP
java \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache" \
  -Djavacpp.platform=linux-x86_64 \
  -Djavacpp.cache.dir=/tmp/javacpp-cache \
  -Djavacpp.verbose=true \
  -Djavacpp.skip=false \
  -Djava.awt.headless=true \
  -cp "lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR"

echo "✅ Ejecución completada"
