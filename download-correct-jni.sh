#!/bin/bash

echo "🔍 Descargando librerías JNI correctas para Audiveris..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

echo "📥 Descargando librerías JNI específicas de linux-x86_64..."

# URLs específicas para librerías JNI de linux-x86_64
LEPTONICA_JNI_URL="https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.83.0-1.5.9/leptonica-1.83.0-1.5.9-linux-x86_64.jar"
TESSERACT_JNI_URL="https://repo1.maven.org/maven2/org/bytedeco/tesseract/5.3.1-1.5.9/tesseract-5.3.1-1.5.9-linux-x86_64.jar"

# Función para descargar y extraer librerías JNI
download_and_extract_jni() {
    local url="$1"
    local name="$2"
    local temp_jar="/tmp/${name}-jni.jar"
    
    echo "📥 Descargando ${name} JNI desde: $url"
    
    # Descargar con curl (con reintentos)
    if curl -fsSL --retry 5 --retry-delay 2 "$url" -o "$temp_jar"; then
        if [ -s "$temp_jar" ]; then
            echo "✅ ${name} JNI descargado. Extrayendo librerías .so..."
            
            # Extraer todas las librerías .so al cache
            unzip -o -q "$temp_jar" "*.so*" -d "$JAVACPP_CACHE_DIR" 2>/dev/null || echo "⚠️ No se encontraron .so en ${name}"
            
            # Buscar específicamente librerías JNI
            find "$JAVACPP_CACHE_DIR" -name "libjni*.so*" -exec cp {} "$JAVACPP_CACHE_DIR/" \; 2>/dev/null || echo "⚠️ No se encontraron libjni*.so en ${name}"
            
            # Hacer ejecutables las librerías
            find "$JAVACPP_CACHE_DIR" -name "*.so*" -exec chmod +x {} \; 2>/dev/null
            
            echo "✅ ${name} JNI procesado"
            rm -f "$temp_jar"
            return 0
        else
            echo "❌ ${name} JNI descargado pero vacío"
            rm -f "$temp_jar"
            return 1
        fi
    else
        echo "❌ Error descargando ${name} JNI"
        rm -f "$temp_jar"
        return 1
    fi
}

# Descargar Leptonica JNI
download_and_extract_jni "$LEPTONICA_JNI_URL" "leptonica"

# Descargar Tesseract JNI
download_and_extract_jni "$TESSERACT_JNI_URL" "tesseract"

echo "🔍 Verificando librerías JNI descargadas..."
echo "📁 Contenido del cache:"
ls -la /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No se encontraron librerías .so"

echo "🔍 Buscando específicamente librerías JNI:"
find /tmp/javacpp-cache -name "libjni*.so*" 2>/dev/null || echo "⚠️ No se encontraron librerías libjni*.so"

# Listar todas las librerías encontradas
echo "📋 Todas las librerías en cache:"
find /tmp/javacpp-cache -name "*.so*" 2>/dev/null || echo "⚠️ No hay librerías .so en cache"

echo "✅ Descarga de librerías JNI completada"
