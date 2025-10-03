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
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache:$LD_LIBRARY_PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64
export JAVACPP_VERBOSE=1

# Crear directorio de cache si no existe
mkdir -p /tmp/javacpp-cache

# Cambiar al directorio de Audiveris
cd /app/audiveris-5.4

# Ejecutar Audiveris con configuración optimizada
java \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache" \
  -Djavacpp.platform=linux-x86_64 \
  -Djavacpp.cache.dir=/tmp/javacpp-cache \
  -Djavacpp.verbose=true \
  -cp "lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR"

echo "✅ Ejecución completada"
