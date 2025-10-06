#!/bin/bash

echo "🚀 Descargando y empaquetando librerías JNI definitivas..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache
mkdir -p /app/jni-libs

cd /app/audiveris-5.4

echo "📥 Descargando JARs platform completos..."

# URLs de los JARs platform (sin clasificador para que incluyan todas las plataformas)
LEPTONICA_URL="https://repo1.maven.org/maven2/org/bytedeco/leptonica-platform/1.83.0-1.5.9/leptonica-platform-1.83.0-1.5.9.jar"
TESSERACT_URL="https://repo1.maven.org/maven2/org/bytedeco/tesseract-platform/5.3.1-1.5.9/tesseract-platform-5.3.1-1.5.9.jar"

# Descargar JARs platform completos
echo "📥 Descargando leptonica-platform..."
curl -fsSL --retry 5 "$LEPTONICA_URL" -o "/app/jni-libs/leptonica-platform.jar" || {
  echo "⚠️ Falló curl, probando wget...";
  wget -q "$LEPTONICA_URL" -O "/app/jni-libs/leptonica-platform.jar";
}

echo "📥 Descargando tesseract-platform..."
curl -fsSL --retry 5 "$TESSERACT_URL" -o "/app/jni-libs/tesseract-platform.jar" || {
  echo "⚠️ Falló curl, probando wget...";
  wget -q "$TESSERACT_URL" -O "/app/jni-libs/tesseract-platform.jar";
}

echo "📦 Extrayendo librerías JNI específicas para linux-x86_64..."

# Extraer solo las librerías JNI de linux-x86_64
unzip -o -q "/app/jni-libs/leptonica-platform.jar" -d "/tmp/javacpp-temp"
unzip -o -q "/app/jni-libs/tesseract-platform.jar" -d "/tmp/javacpp-temp"

# Copiar librerías JNI específicas de linux-x86_64
echo "🔍 Copiando librerías JNI de linux-x86_64..."
find /tmp/javacpp-temp -path "*/linux-x86_64/*" -name "libjnileptonica*.so*" -exec cp {} /app/jni-libs/ \;
find /tmp/javacpp-temp -path "*/linux-x86_64/*" -name "libjnitesseract*.so*" -exec cp {} /app/jni-libs/ \;

# Copiar también las dependencias nativas
find /tmp/javacpp-temp -path "*/linux-x86_64/*" -name "*.so*" -exec cp {} /app/jni-libs/ \;

# Hacer ejecutables las librerías
chmod +x /app/jni-libs/*.so*

echo "📁 Librerías JNI empaquetadas:"
ls -la /app/jni-libs/

# Limpiar temporal
rm -rf /tmp/javacpp-temp

echo "✅ Librerías JNI empaquetadas correctamente en /app/jni-libs/"
