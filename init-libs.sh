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

# Crear enlaces simbólicos para las librerías nativas
echo "🔗 Creando enlaces simbólicos para librerías nativas..."
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/lib/liblept.so 2>/dev/null && echo "✅ Enlace creado para liblept.so" || echo "⚠️ No se pudo crear enlace para liblept.so"
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/lib/libtesseract.so 2>/dev/null && echo "✅ Enlace creado para libtesseract.so" || echo "⚠️ No se pudo crear enlace para libtesseract.so"

# Configurar variables de entorno para JavaCPP
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

echo "🔧 Variables de entorno configuradas:"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "JAVACPP_CACHE_DIR: $JAVACPP_CACHE_DIR"
echo "JAVACPP_PLATFORM: $JAVACPP_PLATFORM"

echo "✅ Inicialización completada"
