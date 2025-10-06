#!/bin/bash

echo "🚀 EMPAQUETANDO TODAS LAS LIBRERÍAS JNI DEFINITIVAMENTE..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache y librerías empaquetadas
mkdir -p /tmp/javacpp-cache
mkdir -p /app/jni-libs-bundled

cd /app/audiveris-5.4

echo "📦 DESCARGANDO TODAS LAS LIBRERÍAS JNI POSIBLES..."

# URLs específicas para librerías JNI de linux-x86_64
JNI_LIBRARIES=(
    "https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.83.0-1.5.9/leptonica-1.83.0-1.5.9-linux-x86_64.jar"
    "https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.3.1-1.5.9/tesseract-5.3.1-1.5.9-linux-x86_64.jar"
    "https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.82.0-1.5.9/leptonica-1.82.0-1.5.9-linux-x86_64.jar"
    "https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.3.0-1.5.9/tesseract-5.3.0-1.5.9-linux-x86_64.jar"
    "https://repo1.maven.org/maven2/org/bytedeco/opencv/4.8.1-1.5.9/opencv-4.8.1-1.5.9-linux-x86_64.jar"
)

# Función para descargar y extraer librerías JNI
download_and_extract_all() {
    local url="$1"
    local name=$(basename "$url" .jar)
    
    echo "📥 Descargando $name..."
    
    if curl -fsSL --retry 3 --retry-delay 2 "$url" -o "/tmp/${name}.jar"; then
        if [ -s "/tmp/${name}.jar" ]; then
            echo "✅ $name descargado. Extrayendo librerías .so..."
            
            # Extraer TODAS las librerías .so
            unzip -o -q "/tmp/${name}.jar" "*.so*" -d "/tmp/javacpp-cache" 2>/dev/null || echo "⚠️ No .so en $name"
            
            # Extraer también a librerías empaquetadas
            unzip -o -q "/tmp/${name}.jar" "*.so*" -d "/app/jni-libs-bundled" 2>/dev/null || echo "⚠️ No .so en $name"
            
            # Buscar específicamente librerías JNI
            find "/tmp/${name}.jar" -exec unzip -o -q {} "org/bytedeco/*/linux-x86_64/*.so" -d "/tmp/javacpp-cache" \; 2>/dev/null || echo "⚠️ No JNI en $name"
            
            rm -f "/tmp/${name}.jar"
            return 0
        else
            echo "❌ $name vacío"
            rm -f "/tmp/${name}.jar"
            return 1
        fi
    else
        echo "❌ Error descargando $name"
        return 1
    fi
}

# Descargar todas las librerías
for url in "${JNI_LIBRARIES[@]}"; do
    download_and_extract_all "$url" || echo "⚠️ Falló $url, continuando..."
done

echo "🔍 BUSCANDO TODAS LAS LIBRERÍAS EXTRAÍDAS..."

# Buscar TODAS las librerías .so en el cache
echo "📁 Librerías en /tmp/javacpp-cache:"
find /tmp/javacpp-cache -name "*.so*" -exec ls -la {} \;

# Buscar librerías JNI específicas
echo "🔍 Librerías JNI encontradas:"
find /tmp/javacpp-cache -name "libjni*.so*" -exec ls -la {} \;

# Copiar TODAS las librerías .so al directorio de Audiveris
echo "📦 Copiando librerías al directorio de Audiveris..."
find /tmp/javacpp-cache -name "*.so*" -exec cp {} /app/audiveris-5.4/ \;

# Hacer ejecutables TODAS las librerías
echo "🔧 Haciendo ejecutables todas las librerías..."
find /app/audiveris-5.4 -name "*.so*" -exec chmod +x {} \; 2>/dev/null
find /tmp/javacpp-cache -name "*.so*" -exec chmod +x {} \; 2>/dev/null

echo "📋 LIBRERÍAS FINALES EN AUDIVERIS:"
ls -la /app/audiveris-5.4/*.so* 2>/dev/null || echo "⚠️ No hay librerías .so en audiveris-5.4"

echo "📋 LIBRERÍAS FINALES EN CACHE:"
ls -la /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No hay librerías .so en cache"

echo "🎯 EMPAQUETADO DEFINITIVO COMPLETADO"
