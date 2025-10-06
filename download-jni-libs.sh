#!/bin/bash

echo "🔧 Descargando librerías JNI de JavaCPP..."

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

# URLs base para las librerías JNI
BASE_URL="https://github.com/bytedeco/javacpp-presets/releases/download"
VERSION="1.5.9"

# Descargar librerías JNI específicas
download_jni() {
    local lib_name=$1
    local file_name="${lib_name}-${VERSION}-1.5-linux-x86_64.jar"
    local url="${BASE_URL}/${VERSION}/${file_name}"
    
    echo "📥 Descargando ${lib_name}..."
    
    # Descargar JAR
    wget -q "${url}" -O "/tmp/${file_name}"
    
    if [ $? -eq 0 ]; then
        echo "✅ ${lib_name} descargado"
        
        # Extraer librerías .so del JAR
        unzip -q "/tmp/${file_name}" "*.so" -d "/tmp/javacpp-cache/"
        
        if [ $? -eq 0 ]; then
            echo "✅ Librerías .so extraídas para ${lib_name}"
        else
            echo "⚠️ No se encontraron librerías .so en ${lib_name}"
        fi
        
        # Limpiar JAR temporal
        rm -f "/tmp/${file_name}"
    else
        echo "❌ Error descargando ${lib_name}"
    fi
}

# Descargar librerías necesarias
download_jni "leptonica"
download_jni "tesseract"
download_jni "opencv"

# Buscar y copiar librerías JNI específicas
echo "🔍 Buscando librerías JNI extraídas..."

find /tmp/javacpp-cache -name "*.so" -exec cp {} /tmp/javacpp-cache/ \;

# Listar librerías encontradas
echo "📁 Librerías JNI disponibles:"
ls -la /tmp/javacpp-cache/*.so 2>/dev/null || echo "⚠️ No se encontraron librerías .so"

# Configurar permisos
chmod 755 /tmp/javacpp-cache/*.so 2>/dev/null

echo "✅ Descarga de librerías JNI completada"
