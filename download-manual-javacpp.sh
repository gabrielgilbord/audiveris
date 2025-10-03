#!/bin/bash

echo "📥 Descargando librerías JavaCPP manualmente..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

set -e

echo "🔧 Descargando librerías JavaCPP específicas..."

# URLs de las librerías JavaCPP "platform" alineadas con el sistema
# Leptonica 1.82.0 (SONAME .5) y Tesseract 5.3.0
LEPTONICA_URL="https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.82.0-1.5.9/leptonica-platform-1.82.0-1.5.9-linux-x86_64.jar"
TESSERACT_URL="https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.0-1.5.9/tesseract-platform-5.3.0-1.5.9-linux-x86_64.jar"

# Crear directorio temporal
TEMP_DIR="/tmp/javacpp-temp"
mkdir -p "$TEMP_DIR"

echo "📥 Descargando Leptonica JAR..."
wget -q "$LEPTONICA_URL" -O "$TEMP_DIR/leptonica.jar" || { echo "❌ Error descargando Leptonica"; exit 1; }
if [ ! -s "$TEMP_DIR/leptonica.jar" ]; then echo "❌ Leptonica JAR vacío"; exit 1; fi

echo "📥 Descargando Tesseract JAR..."
wget -q "$TESSERACT_URL" -O "$TEMP_DIR/tesseract.jar" || { echo "❌ Error descargando Tesseract"; exit 1; }
if [ ! -s "$TEMP_DIR/tesseract.jar" ]; then echo "❌ Tesseract JAR vacío"; exit 1; fi

echo "📦 Extrayendo librerías nativas..."

cd "$TEMP_DIR"

# Extraer directamente al directorio de cache para que JavaCPP las encuentre
echo "🔍 Extrayendo de leptonica.jar..."
unzip -o -q "$TEMP_DIR/leptonica.jar" -d "$JAVACPP_CACHE_DIR"

echo "🔍 Extrayendo de tesseract.jar..."
unzip -o -q "$TEMP_DIR/tesseract.jar" -d "$JAVACPP_CACHE_DIR"

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

# Mostrar principales librerías extraídas
echo "📁 Librerías extraídas (resumen):"
find "$JAVACPP_CACHE_DIR" -type f \( -name "libjnileptonica*.so*" -o -name "libjnitesseract*.so*" \) | head -20

echo "🔍 Verificando librerías descargadas..."
ls -la /tmp/javacpp-cache/

echo "✅ Descarga manual completada"
