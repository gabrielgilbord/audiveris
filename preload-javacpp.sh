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

echo "📚 Pre-cargando clases JavaCPP..."

# Crear un archivo Java temporal para forzar descarga de librerías
cat > /tmp/PreloadJavaCPP.java << 'EOF'
import org.bytedeco.javacpp.Loader;
import org.bytedeco.leptonica.global.leptonica;
import org.bytedeco.tesseract.global.tesseract;

public class PreloadJavaCPP {
    public static void main(String[] args) {
        try {
            // Forzar descarga de librerías JavaCPP
            System.setProperty("javacpp.download", "true");
            System.setProperty("javacpp.extract", "true");
            
            System.out.println("🔧 Pre-cargando Leptonica...");
            Loader.load(leptonica.class);
            System.out.println("✅ Leptonica cargado correctamente");
            
            System.out.println("🔧 Pre-cargando Tesseract...");
            Loader.load(tesseract.class);
            System.out.println("✅ Tesseract cargado correctamente");
            
            System.out.println("🎉 Todas las librerías JavaCPP cargadas exitosamente");
        } catch (Exception e) {
            System.err.println("❌ Error pre-cargando librerías: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
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

echo "✅ Pre-carga completada"
