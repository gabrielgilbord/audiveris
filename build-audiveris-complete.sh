#!/bin/bash

echo "🏗️ CONSTRUYENDO AUDIVERIS COMPLETO DESDE CERO..."

# Instalar dependencias adicionales necesarias
echo "📦 INSTALANDO DEPENDENCIAS ADICIONALES..."
apt-get update && apt-get install -y \
    cmake pkg-config \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

echo "🔧 CONFIGURANDO ENTORNO JAVA..."

# Configurar variables de entorno
export JAVA_HOME=/usr/local/openjdk-21
export PATH="$JAVA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH"
export JAVA_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:/usr/local/lib"
export JAVACPP_CACHE_DIR=/tmp/javacpp-cache
export JAVACPP_PLATFORM=linux-x86_64
export JAVACPP_VERBOSE=1

echo "🔧 CONFIGURANDO ENLACES SIMBÓLICOS..."

# Crear directorio de cache
mkdir -p /tmp/javacpp-cache

# Crear enlaces simbólicos para librerías nativas
ln -sf /usr/lib/x86_64-linux-gnu/liblept.so.5.0.4 /usr/lib/liblept.so 2>/dev/null || echo "⚠️ No se pudo crear enlace para liblept.so"
ln -sf /usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3 /usr/lib/libtesseract.so 2>/dev/null || echo "⚠️ No se pudo crear enlace para libtesseract.so"

echo "🔧 ACTUALIZANDO CACHE DE LIBRERÍAS..."

# Forzar la descarga y extracción de librerías JNI
cd /tmp/javacpp-cache

# Crear un programa Java para forzar la extracción de JNI
cat > /tmp/ExtractJNI.java << 'EOF'
import java.io.File;
import java.lang.reflect.Method;

public class ExtractJNI {
    public static void main(String[] args) {
        try {
            // Configurar java.library.path
            System.setProperty("java.library.path", 
                "/usr/lib/x86_64-linux-gnu" + File.pathSeparator + 
                "/usr/lib" + File.pathSeparator + 
                "/usr/local/lib" + File.pathSeparator +
                "/tmp/javacpp-cache");
            
            // Forzar recarga del ClassLoader
            Method methodSysPath = ClassLoader.class.getDeclaredMethod("sys_paths", String.class);
            methodSysPath.setAccessible(true);
            methodSysPath.invoke(null, (Object) null);
            
            System.out.println("✅ java.library.path configurado");
            
            // Intentar cargar librerías usando JavaCPP Loader
            try {
                Class<?> loaderClass = Class.forName("org.bytedeco.javacpp.Loader");
                Method loadMethod = loaderClass.getMethod("load", Class.class);
                
                // Cargar Leptonica
                Class<?> leptonicaClass = Class.forName("org.bytedeco.leptonica.global.leptonica");
                loadMethod.invoke(null, leptonicaClass);
                System.out.println("✅ Leptonica cargada via JavaCPP");
                
                // Cargar Tesseract
                Class<?> tesseractClass = Class.forName("org.bytedeco.tesseract.global.tesseract");
                loadMethod.invoke(null, tesseractClass);
                System.out.println("✅ Tesseract cargada via JavaCPP");
                
            } catch (Exception e) {
                System.out.println("⚠️ JavaCPP no disponible, usando método alternativo");
                
                // Método alternativo: intentar cargar directamente
                try {
                    System.loadLibrary("jnileptonica");
                    System.out.println("✅ jnileptonica cargada directamente");
                } catch (UnsatisfiedLinkError ex) {
                    System.out.println("⚠️ jnileptonica no encontrada: " + ex.getMessage());
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Compilar y ejecutar el programa de extracción
echo "📝 Compilando programa de extracción JNI..."
javac /tmp/ExtractJNI.java

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa"
    echo "🚀 Ejecutando extracción JNI..."
    
    # Ejecutar con classpath que incluya las librerías JavaCPP
    java -cp "/tmp:/app/audiveris-5.4/lib/*" ExtractJNI
else
    echo "❌ Error en compilación"
fi

# Limpiar archivos temporales
rm -f /tmp/ExtractJNI.java /tmp/ExtractJNI.class

# Verificar librerías extraídas
echo "🔍 Verificando librerías JNI extraídas..."
find /tmp/javacpp-cache -name "*.so" -exec ls -la {} \;

echo "✅ CONSTRUCCIÓN COMPLETA DE AUDIVERIS FINALIZADA"