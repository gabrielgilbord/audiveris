#!/bin/bash

echo "🔧 Inicializando librerías nativas para Audiveris..."

# Verificar Java
echo "☕ Verificando Java..."
java -version
echo "JAVA_HOME: $JAVA_HOME"

# Verificar Tesseract
echo "🔤 Verificando Tesseract..."
tesseract --version

# Buscar y configurar librerías nativas
echo "📚 Configurando librerías nativas..."

# Buscar todas las librerías de Leptonica
echo "🔍 Buscando librerías de Leptonica..."
find /usr -name "*lept*" -type f 2>/dev/null | head -10

# Buscar todas las librerías de Tesseract
echo "🔍 Buscando librerías de Tesseract..."
find /usr -name "*tesseract*" -type f 2>/dev/null | head -10

# Crear directorio para librerías nativas de Java
mkdir -p /tmp/javacpp-cache

# Configurar variables de entorno para JavaCPP
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

echo "🔧 Variables de entorno configuradas:"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "JAVACPP_CACHE_DIR: $JAVACPP_CACHE_DIR"
echo "JAVACPP_PLATFORM: $JAVACPP_PLATFORM"

# Intentar descargar las librerías nativas de JavaCPP
echo "📥 Intentando descargar librerías nativas de JavaCPP..."
cd /app/audiveris-5.4/lib
java -cp "*" org.bytedeco.javacpp.Loader -platform linux-x86_64 || echo "⚠️ No se pudieron descargar todas las librerías"

echo "✅ Inicialización completada"
