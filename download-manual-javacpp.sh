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

echo "🔧 Descargando librerías JavaCPP específicas..."

# URLs de las librerías JavaCPP para linux-x86_64
LEPTONICA_URL="https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.83.0-1.5.9/leptonica-1.83.0-1.5.9-linux-x86_64.jar"
TESSERACT_URL="https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.2.0-1.5.9/tesseract-5.2.0-1.5.9-linux-x86_64.jar"

# Crear directorio temporal
TEMP_DIR="/tmp/javacpp-temp"
mkdir -p "$TEMP_DIR"

echo "📥 Descargando Leptonica JAR..."
wget -q "$LEPTONICA_URL" -O "$TEMP_DIR/leptonica.jar" || echo "⚠️ Error descargando Leptonica"

echo "📥 Descargando Tesseract JAR..."
wget -q "$TESSERACT_URL" -O "$TEMP_DIR/tesseract.jar" || echo "⚠️ Error descargando Tesseract"

# Extraer librerías nativas de los JARs
echo "📦 Extrayendo librerías nativas..."

cd "$TEMP_DIR"

# Extraer de Leptonica
if [ -f "leptonica.jar" ]; then
    echo "🔍 Extrayendo de leptonica.jar..."
    jar -xf leptonica.jar
    find . -name "*.so" -exec cp {} /tmp/javacpp-cache/ \;
    find . -name "jnileptonica*" -exec cp {} /tmp/javacpp-cache/ \;
fi

# Extraer de Tesseract
if [ -f "tesseract.jar" ]; then
    echo "🔍 Extrayendo de tesseract.jar..."
    jar -xf tesseract.jar
    find . -name "*.so" -exec cp {} /tmp/javacpp-cache/ \;
    find . -name "jnitesseract*" -exec cp {} /tmp/javacpp-cache/ \;
fi

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"

# Hacer ejecutables las librerías
chmod +x /tmp/javacpp-cache/*.so 2>/dev/null || true

echo "🔍 Verificando librerías descargadas..."
ls -la /tmp/javacpp-cache/

echo "✅ Descarga manual completada"
