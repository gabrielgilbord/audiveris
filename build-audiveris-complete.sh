#!/bin/bash

echo "🏗️ CONSTRUYENDO AUDIVERIS COMPLETO DESDE CERO..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:$LD_LIBRARY_PATH"
export TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/

cd /app/audiveris-5.4

echo "📦 INSTALANDO DEPENDENCIAS ADICIONALES..."

# Instalar TODAS las dependencias posibles
apt-get update && apt-get install -y \
    build-essential cmake pkg-config \
    libtesseract-dev libleptonica-dev \
    tesseract-ocr tesseract-ocr-eng tesseract-ocr-spa \
    libopencv-dev libavcodec-dev libavformat-dev \
    libswscale-dev libv4l-dev libxvidcore-dev \
    libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    libatlas-base-dev gfortran libfreetype6-dev \
    zlib1g-dev libgtk-3-dev libcanberra-gtk3-dev \
    && rm -rf /var/lib/apt/lists/*

echo "🔧 CONFIGURANDO ENTORNO JAVA..."

# Crear un script de ejecución personalizado
cat > /app/audiveris-5.4/run-audiveris-custom.sh << 'EOF'
#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"

echo "🚀 Ejecutando Audiveris con configuración personalizada..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib"
export TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/
export CLASSPATH="/app/audiveris-5.4/lib/*"

# Crear directorio de salida
mkdir -p "$OUTPUT_DIR"

cd /app/audiveris-5.4

echo "📁 Archivo: $INPUT_FILE"
echo "📁 Salida: $OUTPUT_DIR"

# Verificar librerías
echo "🔍 Verificando librerías..."
ldconfig -p | grep -E "(lept|tesseract)" || echo "⚠️ Librerías no encontradas en ldconfig"

# Ejecutar Audiveris con configuración ultra-completa
java \
  -Djava.awt.headless=true \
  -Djavacpp.skip=true \
  -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib" \
  -Dfile.encoding=UTF-8 \
  -Duser.timezone=UTC \
  -Xmx4g \
  -Xms1g \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -Djava.awt.graphicsenv=sun.awt.X11GraphicsEnvironment \
  -Djava.awt.headless=true \
  -Djava.awt.fonts=/usr/share/fonts/truetype \
  -Dsun.java2d.fontpath=/usr/share/fonts/truetype \
  -cp "/app/audiveris-5.4/lib/*" \
  Audiveris \
  -batch "$INPUT_FILE" \
  -export \
  -output "$OUTPUT_DIR"

echo "✅ Ejecución personalizada completada"
EOF

chmod +x /app/audiveris-5.4/run-audiveris-custom.sh

echo "🔧 CONFIGURANDO ENLACES SIMBÓLICOS..."

# Crear TODOS los enlaces simbólicos posibles
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/lib/liblept.so 2>/dev/null || true
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/lib/libtesseract.so 2>/dev/null || true
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/local/lib/liblept.so 2>/dev/null || true
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/local/lib/libtesseract.so 2>/dev/null || true

echo "🔧 ACTUALIZANDO CACHE DE LIBRERÍAS..."
ldconfig

echo "✅ CONSTRUCCIÓN COMPLETA DE AUDIVERIS FINALIZADA"
