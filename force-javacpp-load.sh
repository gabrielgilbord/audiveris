#!/bin/bash

echo "🚀 Forzando carga de librerías JavaCPP con Java directo..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64
export JAVACPP_VERBOSE=1

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

echo "🔧 Forzando extracción de librerías JavaCPP..."

# Crear un programa Java simple que fuerce la carga de las librerías
cat > /tmp/ForceJavaCPPLoad.java << 'EOF'
import org.bytedeco.javacpp.Loader;
import org.bytedeco.leptonica.global.leptonica;
import org.bytedeco.tesseract.global.tesseract;

public class ForceJavaCPPLoad {
    public static void main(String[] args) {
        try {
            System.out.println("🔧 Forzando carga de Leptonica...");
            System.setProperty("javacpp.platform", "linux-x86_64");
            System.setProperty("javacpp.cache.dir", "/tmp/javacpp-cache");
            System.setProperty("javacpp.verbose", "true");
            System.setProperty("javacpp.skip", "false");
            System.setProperty("javacpp.download", "true");
            System.setProperty("javacpp.extract", "true");
            
            Loader.load(leptonica.class);
            System.out.println("✅ Leptonica cargado correctamente");
            
            System.out.println("🔧 Forzando carga de Tesseract...");
            Loader.load(tesseract.class);
            System.out.println("✅ Tesseract cargado correctamente");
            
            System.out.println("🎉 Todas las librerías JavaCPP cargadas exitosamente");
            
        } catch (Exception e) {
            System.err.println("❌ Error cargando librerías JavaCPP: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
EOF

echo "📝 Compilando programa de carga forzada..."
if javac -cp "lib/*" /tmp/ForceJavaCPPLoad.java; then
    echo "✅ Compilación exitosa"
    
    echo "🚀 Ejecutando carga forzada de librerías..."
    java \
        -Djavacpp.platform=linux-x86_64 \
        -Djavacpp.cache.dir=/tmp/javacpp-cache \
        -Djavacpp.verbose=true \
        -Djavacpp.skip=false \
        -Djavacpp.download=true \
        -Djavacpp.extract=true \
        -Djava.library.path="/usr/lib/x86_64-linux-gnu:/usr/lib:/tmp/javacpp-cache" \
        -cp "/tmp:lib/*" \
        ForceJavaCPPLoad
        
    echo "🔍 Verificando librerías extraídas..."
    echo "📁 Contenido del cache después de la carga:"
    ls -la /tmp/javacpp-cache/*.so* 2>/dev/null || echo "⚠️ No se encontraron librerías .so"
    
    echo "🔍 Buscando librerías JNI específicas:"
    find /tmp/javacpp-cache -name "libjni*.so*" 2>/dev/null || echo "⚠️ No se encontraron librerías libjni*.so"
    
else
    echo "❌ Error en la compilación"
    exit 1
fi

# Limpiar archivos temporales
rm -f /tmp/ForceJavaCPPLoad.java /tmp/ForceJavaCPPLoad.class

echo "✅ Carga forzada de librerías JavaCPP completada"
