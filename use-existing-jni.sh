#!/bin/bash

echo "🔍 Usando librerías JNI existentes de audiveris-5.4/lib..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

echo "🔍 Buscando librerías JNI en lib/..."
ls -la lib/leptonica-1.83.0-1.5.9.jar lib/tesseract-5.3.1-1.5.9.jar 2>/dev/null || echo "⚠️ JARs no encontrados"

echo "📦 Extrayendo librerías JNI de JARs existentes..."

# Buscar y extraer librerías JNI de los JARs existentes
mkdir -p /tmp/javacpp-temp
for jar in lib/leptonica-1.83.0-1.5.9.jar lib/tesseract-5.3.1-1.5.9.jar; do
    if [ -f "$jar" ]; then
        echo "📦 Extrayendo de: $jar"
        unzip -o -q "$jar" -d /tmp/javacpp-temp/
    fi
done

echo "🔍 Copiando librerías JNI encontradas..."
find /tmp/javacpp-temp -name "libjni*.so*" -exec cp {} /tmp/javacpp-cache/ \;
find /tmp/javacpp-temp -name "*.so*" -exec cp {} /tmp/javacpp-cache/ \;

# Hacer ejecutables las librerías
chmod +x /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No se pudieron hacer ejecutables las librerías"

echo "📁 Librerías JNI en cache:"
ls -la /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No se encontraron librerías .so"

# Limpiar temporal
rm -rf /tmp/javacpp-temp

echo "✅ Librerías JNI configuradas desde JARs existentes"
