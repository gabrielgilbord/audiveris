#!/bin/bash

echo "🔧 SOLUCIONANDO PROBLEMA DE LIBRERÍAS JNI..."

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

# Configurar variables de entorno
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache:$LD_LIBRARY_PATH"
export JAVA_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:/tmp/javacpp-cache"

# Descargar librerías JNI específicas de JavaCPP
echo "📥 Descargando librerías JNI de JavaCPP..."

# URLs para las librerías JNI
LEPTONICA_JNI_URL="https://github.com/bytedeco/javacpp-presets/releases/download/leptonica-1.5.9/leptonica-1.5.9-1.5-linux-x86_64.jar"
TESSERACT_JNI_URL="https://github.com/bytedeco/javacpp-presets/releases/download/tesseract-1.5.9/tesseract-1.5.9-1.5-linux-x86_64.jar"

# Función para descargar y extraer JNI
download_and_extract_jni() {
    local url=$1
    local name=$2
    
    echo "📥 Descargando $name..."
    wget -q "$url" -O "/tmp/${name}.jar"
    
    if [ $? -eq 0 ]; then
        echo "✅ $name descargado"
        
        # Extraer librerías .so
        unzip -q "/tmp/${name}.jar" "*.so" -d "/tmp/javacpp-cache/"
        
        if [ $? -eq 0 ]; then
            echo "✅ Librerías .so extraídas para $name"
        else
            echo "⚠️ No se encontraron librerías .so en $name"
        fi
        
        # Limpiar JAR temporal
        rm -f "/tmp/${name}.jar"
    else
        echo "❌ Error descargando $name"
    fi
}

# Descargar librerías
download_and_extract_jni "$LEPTONICA_JNI_URL" "leptonica"
download_and_extract_jni "$TESSERACT_JNI_URL" "tesseract"

# Buscar y copiar todas las librerías JNI
echo "🔍 Buscando librerías JNI extraídas..."
find /tmp/javacpp-cache -name "*.so" -exec cp {} /tmp/javacpp-cache/ \;

# Configurar permisos
chmod 755 /tmp/javacpp-cache/*.so 2>/dev/null

# Listar librerías encontradas
echo "📁 Librerías JNI disponibles:"
ls -la /tmp/javacpp-cache/*.so 2>/dev/null || echo "⚠️ No se encontraron librerías .so"

# Crear enlaces simbólicos adicionales
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/lib/liblept.so 2>/dev/null || true
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/lib/libtesseract.so 2>/dev/null || true

echo "✅ CONFIGURACIÓN DE LIBRERÍAS JNI COMPLETADA"
