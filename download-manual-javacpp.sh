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

# Candidatos de URLs para Leptonica y Tesseract (probar en cascada)
LEPTONICA_CANDIDATES=(
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.83.1-1.5.9/leptonica-platform-1.83.1-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.83.0-1.5.9/leptonica-platform-1.83.0-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.82.0-1.5.9/leptonica-platform-1.82.0-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.83.0-1.5.9/leptonica-1.83.0-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.82.0-1.5.9/leptonica-1.82.0-1.5.9-linux-x86_64.jar"
)

TESSERACT_CANDIDATES=(
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.1-1.5.9/tesseract-platform-5.3.1-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.0-1.5.9/tesseract-platform-5.3.0-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.3.1-1.5.9/tesseract-5.3.1-1.5.9-linux-x86_64.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.3.0-1.5.9/tesseract-5.3.0-1.5.9-linux-x86_64.jar"
)

# Crear directorio temporal
TEMP_DIR="/tmp/javacpp-temp"
mkdir -p "$TEMP_DIR"

echo "📥 Descargando Leptonica JAR (con fallback de versiones)..."
LEPTONICA_OK=0
for URL in "${LEPTONICA_CANDIDATES[@]}"; do
  echo "➡️ Intentando: $URL"
  if curl -fsSL --retry 5 --retry-delay 2 "$URL" -o "$TEMP_DIR/leptonica.jar"; then
    if [ -s "$TEMP_DIR/leptonica.jar" ]; then LEPTONICA_OK=1; echo "✅ Descargado Leptonica"; break; fi
  fi
  echo "⚠️ Falló curl, probando wget..."
  if wget -q "$URL" -O "$TEMP_DIR/leptonica.jar" && [ -s "$TEMP_DIR/leptonica.jar" ]; then LEPTONICA_OK=1; echo "✅ Descargado Leptonica (wget)"; break; fi
done
if [ "$LEPTONICA_OK" -ne 1 ]; then echo "❌ No se pudo descargar ningún JAR de Leptonica"; exit 1; fi

echo "📥 Descargando Tesseract JAR (con fallback de versiones)..."
TESSERACT_OK=0
for URL in "${TESSERACT_CANDIDATES[@]}"; do
  echo "➡️ Intentando: $URL"
  if curl -fsSL --retry 5 --retry-delay 2 "$URL" -o "$TEMP_DIR/tesseract.jar"; then
    if [ -s "$TEMP_DIR/tesseract.jar" ]; then TESSERACT_OK=1; echo "✅ Descargado Tesseract"; break; fi
  fi
  echo "⚠️ Falló curl, probando wget..."
  if wget -q "$URL" -O "$TEMP_DIR/tesseract.jar" && [ -s "$TEMP_DIR/tesseract.jar" ]; then TESSERACT_OK=1; echo "✅ Descargado Tesseract (wget)"; break; fi
done
if [ "$TESSERACT_OK" -ne 1 ]; then echo "❌ No se pudo descargar ningún JAR de Tesseract"; exit 1; fi

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
