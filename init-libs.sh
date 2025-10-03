#!/bin/bash

echo "🔧 Inicializando librerías nativas para Audiveris..."

# Crear enlaces simbólicos para las librerías nativas
echo "📚 Creando enlaces simbólicos..."

# Buscar librerías de Leptonica
LEPTONICA_LIB=$(find /usr/lib -name "liblept.so*" 2>/dev/null | head -1)
if [ -n "$LEPTONICA_LIB" ]; then
    echo "✅ Encontrada Leptonica: $LEPTONICA_LIB"
    ln -sf "$LEPTONICA_LIB" /usr/lib/liblept.so
else
    echo "❌ No se encontró Leptonica"
fi

# Buscar librerías de Tesseract
TESSERACT_LIB=$(find /usr/lib -name "libtesseract.so*" 2>/dev/null | head -1)
if [ -n "$TESSERACT_LIB" ]; then
    echo "✅ Encontrada Tesseract: $TESSERACT_LIB"
    ln -sf "$TESSERACT_LIB" /usr/lib/libtesseract.so
else
    echo "❌ No se encontró Tesseract"
fi

# Verificar Java
echo "☕ Verificando Java..."
java -version

# Verificar Tesseract
echo "🔤 Verificando Tesseract..."
tesseract --version

echo "✅ Inicialización completada"
