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

# Candidatos de URLs para Leptonica y Tesseract (JARs "platform" sin clasificador)
LEPTONICA_CANDIDATES=(
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.83.1-1.5.9/leptonica-platform-1.83.1-1.5.9.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.83.0-1.5.9/leptonica-platform-1.83.0-1.5.9.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.82.0-1.5.9/leptonica-platform-1.82.0-1.5.9.jar"
)

TESSERACT_CANDIDATES=(
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.1-1.5.9/tesseract-platform-5.3.1-1.5.9.jar"
  "https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.0-1.5.9/tesseract-platform-5.3.0-1.5.9.jar"
)

# Crear directorio temporal
TEMP_DIR="/tmp/javacpp-temp"
mkdir -p "$TEMP_DIR"
LIB_DIR="/app/audiveris-5.4/lib"

echo "📥 Descargando Leptonica JAR (con fallback de versiones)..."
LEPTONICA_OK=0
for URL in "${LEPTONICA_CANDIDATES[@]}"; do
  echo "➡️ Intentando: $URL"
  BASENAME=$(basename "$URL")
  DEST="$LIB_DIR/$BASENAME"
  if curl -fsSL --retry 5 --retry-delay 2 "$URL" -o "$DEST"; then
    if [ -s "$DEST" ]; then LEPTONICA_OK=1; echo "✅ Guardado en $DEST"; break; fi
  fi
  echo "⚠️ Falló curl, probando wget..."
  if wget -q "$URL" -O "$DEST" && [ -s "$DEST" ]; then LEPTONICA_OK=1; echo "✅ Guardado en $DEST (wget)"; break; fi
done
if [ "$LEPTONICA_OK" -ne 1 ]; then echo "❌ No se pudo descargar ningún JAR de Leptonica"; exit 1; fi

echo "📥 Descargando Tesseract JAR (con fallback de versiones)..."
TESSERACT_OK=0
for URL in "${TESSERACT_CANDIDATES[@]}"; do
  echo "➡️ Intentando: $URL"
  BASENAME=$(basename "$URL")
  DEST="$LIB_DIR/$BASENAME"
  if curl -fsSL --retry 5 --retry-delay 2 "$URL" -o "$DEST"; then
    if [ -s "$DEST" ]; then TESSERACT_OK=1; echo "✅ Guardado en $DEST"; break; fi
  fi
  echo "⚠️ Falló curl, probando wget..."
  if wget -q "$URL" -O "$DEST" && [ -s "$DEST" ]; then TESSERACT_OK=1; echo "✅ Guardado en $DEST (wget)"; break; fi
done
if [ "$TESSERACT_OK" -ne 1 ]; then echo "❌ No se pudo descargar ningún JAR de Tesseract"; exit 1; fi

echo "📦 No se extrae manualmente: JavaCPP cargará y extraerá automáticamente desde lib/*"

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

echo "📁 JARs presentes en lib/ (resumen):"
ls -1 "$LIB_DIR" | grep -E "(leptonica|tesseract).*1.5.9.*\\.jar" || true

echo "🔍 Verificando librerías descargadas..."
ls -la /tmp/javacpp-cache/

echo "✅ Descarga manual completada"
