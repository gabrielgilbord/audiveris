#!/bin/bash

echo "🚀 Pre-cargando librerías JavaCPP..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache:$LD_LIBRARY_PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64
export JAVACPP_VERBOSE=1

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

# Cambiar al directorio de Audiveris
cd /app/audiveris-5.4

echo "📥 Forzando descarga de librerías JavaCPP..."

# Primero, intentar descargar las librerías usando el Loader directamente
java -Djavacpp.platform=linux-x86_64 \
     -Djavacpp.cache.dir=/tmp/javacpp-cache \
     -Djavacpp.verbose=true \
     -Djavacpp.download=true \
     -Djavacpp.extract=true \
     -cp "lib/*" \
     org.bytedeco.javacpp.Loader \
     -Djava.library.path="/tmp/javacpp-cache" \
     -Dloader.preload=org.bytedeco.leptonica.global.leptonica,org.bytedeco.tesseract.global.tesseract \
     || echo "⚠️ Error en descarga inicial, continuando..."

# Verificar qué se descargó
echo "🔍 Verificando descargas..."
find /tmp/javacpp-cache -type f -name "*jni*" -o -name "*leptonica*" -o -name "*tesseract*" | head -10

echo "📚 Pre-cargando clases JavaCPP..."

# Crear un archivo Java temporal para forzar descarga de librerías
cat > /tmp/PreloadJavaCPP.java << 'EOF'
import org.bytedeco.javacpp.Loader;
import org.bytedeco.leptonica.global.leptonica;
import org.bytedeco.tesseract.global.tesseract;

public class PreloadJavaCPP {
    public static void main(String[] args) {
        try {
            // Configurar propiedades para forzar descarga
            System.setProperty("javacpp.download", "true");
            System.setProperty("javacpp.extract", "true");
            System.setProperty("javacpp.platform", "linux-x86_64");
            System.setProperty("javacpp.cache.dir", "/tmp/javacpp-cache");
            System.setProperty("javacpp.verbose", "true");
            
            System.out.println("🔧 Configurando JavaCPP...");
            System.out.println("📁 Cache dir: " + System.getProperty("javacpp.cache.dir"));
            System.out.println("🖥️ Platform: " + System.getProperty("javacpp.platform"));
            
            // Intentar cargar Leptonica con manejo de errores
            try {
                System.out.println("🔧 Pre-cargando Leptonica...");
                Loader.load(leptonica.class);
                System.out.println("✅ Leptonica cargado correctamente");
            } catch (Exception e) {
                System.err.println("⚠️ Error cargando Leptonica: " + e.getMessage());
                // Continuar con Tesseract
            }
            
            // Intentar cargar Tesseract con manejo de errores
            try {
                System.out.println("🔧 Pre-cargando Tesseract...");
                Loader.load(tesseract.class);
                System.out.println("✅ Tesseract cargado correctamente");
            } catch (Exception e) {
                System.err.println("⚠️ Error cargando Tesseract: " + e.getMessage());
            }
            
            System.out.println("🎉 Proceso de pre-carga completado");
        } catch (Exception e) {
            System.err.println("❌ Error general: " + e.getMessage());
            e.printStackTrace();
            // No salir con error, continuar
        }
    }
}
EOF

# Compilar y ejecutar el pre-loader
echo "🔨 Compilando pre-loader..."
javac -cp "lib/*" /tmp/PreloadJavaCPP.java

echo "🚀 Ejecutando pre-loader..."
java -Djavacpp.platform=linux-x86_64 \
     -Djavacpp.cache.dir=/tmp/javacpp-cache \
     -Djavacpp.verbose=true \
     -Djavacpp.download=true \
     -Djavacpp.extract=true \
     -cp "/tmp:lib/*" \
     -Djava.library.path="/tmp/javacpp-cache" \
     PreloadJavaCPP

# Verificar el resultado final
echo "🔍 Verificando librerías descargadas..."
find /tmp/javacpp-cache -type f | head -20

# Listar el contenido del directorio
echo "📁 Contenido del directorio cache:"
ls -la /tmp/javacpp-cache/

echo "✅ Pre-carga completada"
