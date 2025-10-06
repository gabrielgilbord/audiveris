#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"

echo "🐳 Ejecutando Audiveris con DOCKER INTERNO..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"

# Crear directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

echo "📁 Archivo de entrada: $INPUT_FILE"
echo "📁 Directorio de salida: $OUTPUT_DIR"

# Verificar si docker está disponible
if command -v docker &> /dev/null; then
    echo "🐳 Docker disponible, ejecutando Audiveris en contenedor..."
    
    # Ejecutar Audiveris en un contenedor Docker con todas las dependencias
    docker run --rm \
        -v "$INPUT_FILE:/input.pdf:ro" \
        -v "$OUTPUT_DIR:/output" \
        -e JAVA_HOME=/usr/local/openjdk-21 \
        -e LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib" \
        openjdk:21-jdk-slim \
        bash -c "
            apt-get update && apt-get install -y \
                tesseract-ocr tesseract-ocr-eng \
                libtesseract-dev libleptonica-dev \
                && java -Djava.awt.headless=true -Djavacpp.skip=true \
                -cp '/app/audiveris-5.4/lib/*' \
                Audiveris -batch /input.pdf -export -output /output
        " 2>/dev/null || echo "⚠️ Docker falló, usando método alternativo..."
else
    echo "⚠️ Docker no disponible, usando método alternativo..."
fi

# Método alternativo: ejecutar directamente con todas las dependencias instaladas
echo "🔧 Método alternativo: ejecutando directamente..."

cd /app/audiveris-5.4

# Ejecutar con configuración mínima
java \
  -Djava.awt.headless=true \
  -Djavacpp.skip=true \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib" \
  -Dfile.encoding=UTF-8 \
  -Xmx2g \
  -cp "lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR" \
  || echo "❌ Ejecución falló"

echo "✅ Ejecución con Docker interno completada"
