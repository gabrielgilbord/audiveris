#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"

echo "🚀 Ejecutando Audiveris SIN JavaCPP - SOLO LIBRERÍAS DEL SISTEMA..."

# Configurar variables de entorno para usar SOLO librerías del sistema
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:$LD_LIBRARY_PATH"
export TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/

# Crear directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Cambiar al directorio de Audiveris
cd /app/audiveris-5.4

echo "📁 Archivo de entrada: $INPUT_FILE"
echo "📁 Directorio de salida: $OUTPUT_DIR"
echo "🔧 Usando SOLO librerías del sistema (SIN JavaCPP)..."

# Verificar que las librerías del sistema están disponibles
echo "🔍 Verificando librerías del sistema..."
ls -la /usr/lib/x86_64-linux-gnu/liblept.so* 2>/dev/null || echo "⚠️ Leptonica no encontrada"
ls -la /usr/lib/x86_64-linux-gnu/libtesseract.so* 2>/dev/null || echo "⚠️ Tesseract no encontrada"

# Ejecutar Audiveris DESHABILITANDO COMPLETAMENTE JavaCPP
java \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib" \
  -Djava.awt.headless=true \
  -Djavacpp.skip=true \
  -Djavacpp.platform=none \
  -Djavacpp.cache.dir=/dev/null \
  -Djavacpp.verbose=false \
  -Dorg.bytedeco.javacpp.loader.skip=true \
  -cp "lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR"

echo "✅ Ejecución SIN JavaCPP completada"
