#!/bin/bash

echo "📥 Descargando librerías JavaCPP manualmente..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

cd /app/audiveris-5.4

echo "🔧 Configurando JavaCPP para descarga..."

# Crear un script Java que fuerce la descarga
cat > /tmp/DownloadJavaCPP.java << 'EOF'
import org.bytedeco.javacpp.Loader;
import org.bytedeco.javacpp.Pointer;
import java.io.File;

public class DownloadJavaCPP {
    public static void main(String[] args) {
        try {
            // Configurar propiedades
            System.setProperty("javacpp.platform", "linux-x86_64");
            System.setProperty("javacpp.cache.dir", "/tmp/javacpp-cache");
            System.setProperty("javacpp.verbose", "true");
            System.setProperty("javacpp.download", "true");
            System.setProperty("javacpp.extract", "true");
            
            System.out.println("📁 Cache directory: " + System.getProperty("javacpp.cache.dir"));
            System.out.println("🖥️ Platform: " + System.getProperty("javacpp.platform"));
            
            // Verificar que el directorio existe
            File cacheDir = new File("/tmp/javacpp-cache");
            if (!cacheDir.exists()) {
                cacheDir.mkdirs();
                System.out.println("✅ Creado directorio cache");
            }
            
            // Intentar descargar librerías de Leptonica
            try {
                System.out.println("📥 Descargando librerías de Leptonica...");
                Loader.loadLibrary("jniLeptonica");
                System.out.println("✅ Librerías de Leptonica descargadas");
            } catch (Exception e) {
                System.out.println("⚠️ Error descargando Leptonica: " + e.getMessage());
            }
            
            // Intentar descargar librerías de Tesseract
            try {
                System.out.println("📥 Descargando librerías de Tesseract...");
                Loader.loadLibrary("jniTesseract");
                System.out.println("✅ Librerías de Tesseract descargadas");
            } catch (Exception e) {
                System.out.println("⚠️ Error descargando Tesseract: " + e.getMessage());
            }
            
            // Listar archivos descargados
            System.out.println("📁 Archivos en cache:");
            File[] files = cacheDir.listFiles();
            if (files != null) {
                for (File file : files) {
                    System.out.println("  - " + file.getName() + " (" + file.length() + " bytes)");
                }
            } else {
                System.out.println("  No hay archivos en el cache");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

echo "🔨 Compilando script de descarga..."
javac -cp "lib/*" /tmp/DownloadJavaCPP.java

echo "🚀 Ejecutando descarga..."
java -Djavacpp.platform=linux-x86_64 \
     -Djavacpp.cache.dir=/tmp/javacpp-cache \
     -Djavacpp.verbose=true \
     -Djavacpp.download=true \
     -Djavacpp.extract=true \
     -cp "/tmp:lib/*" \
     DownloadJavaCPP

echo "🔍 Verificando resultado..."
ls -la /tmp/javacpp-cache/

echo "✅ Descarga completada"
