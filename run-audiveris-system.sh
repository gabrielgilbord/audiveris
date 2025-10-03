#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"

echo "🚀 Ejecutando Audiveris con librerías del sistema..."

# Configurar variables de entorno para usar librerías del sistema
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
echo "🔧 Usando librerías del sistema..."

# Ejecutar Audiveris SIN JavaCPP, usando librerías del sistema
java \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib" \
  -Djava.awt.headless=true \
  -Djavacpp.skip=true \
  -Dorg.bytedeco.javacpp.skip=true \
  -Djavacpp.platform=linux-x86_64 \
  -cp "lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR"

echo "✅ Ejecución completada"
