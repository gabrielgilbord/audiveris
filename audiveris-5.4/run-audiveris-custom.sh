#!/bin/bash

# Script personalizado para ejecutar Audiveris
# Configuración optimizada para el entorno Docker

set -e

# Variables de entrada
INPUT_FILE="$1"
OUTPUT_DIR="$2"

# Verificar parámetros
if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "❌ Error: Se requieren parámetros INPUT_FILE y OUTPUT_DIR"
    echo "Uso: $0 <archivo_entrada> <directorio_salida>"
    exit 1
fi

echo "🎵 [AUDIVERIS] Iniciando conversión de partitura..."
echo "📁 [AUDIVERIS] Archivo: $INPUT_FILE"
echo "📁 [AUDIVERIS] Salida: $OUTPUT_DIR"

# Crear directorio de salida si no existe
mkdir -p "$OUTPUT_DIR"

# Configurar variables de entorno para Java
export JAVA_HOME="/usr/local/openjdk-21"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache"
export JAVACPP_CACHE_DIR="/tmp/javacpp-cache"
export JAVACPP_PLATFORM="linux-x86_64"
export JAVACPP_VERBOSE="1"
export JAVACPP_SKIP="false"
export JAVA_AWT_HEADLESS="true"
export JNA_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache"

# Verificar que Java esté disponible
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java no está disponible"
    exit 1
fi

# Verificar que el archivo de entrada exista
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: El archivo de entrada no existe: $INPUT_FILE"
    exit 1
fi

# Ejecutar Audiveris con configuración personalizada
echo "🚀 [AUDIVERIS] Ejecutando Audiveris con configuración personalizada..."

java \
    -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache" \
    -Djavacpp.platform=linux-x86_64 \
    -Djavacpp.cache.dir=/tmp/javacpp-cache \
    -Djavacpp.verbose=true \
    -Djavacpp.skip=false \
    -Djava.awt.headless=true \
    -Djna.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache" \
    -Xmx2g \
    -XX:+UseG1GC \
    -cp "lib/*" \
    Audiveris \
    -batch "$INPUT_FILE" \
    -export \
    -output "$OUTPUT_DIR"

# Verificar el resultado
if [ $? -eq 0 ]; then
    echo "✅ [AUDIVERIS] Conversión completada exitosamente"
    
    # Listar archivos generados
    if [ -d "$OUTPUT_DIR" ]; then
        echo "📁 [AUDIVERIS] Archivos generados:"
        ls -la "$OUTPUT_DIR" || echo "⚠️ No se pudieron listar los archivos"
    fi
else
    echo "❌ [AUDIVERIS] Error durante la conversión"
    exit 1
fi
