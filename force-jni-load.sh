#!/bin/bash

echo "🚀 Forzando carga de librerías JNI..."

# Crear directorio de cache si no existe
mkdir -p /tmp/javacpp-cache

# Configurar variables de entorno
export LD_LIBRARY_PATH="/tmp/javacpp-cache:/usr/lib/x86_64-linux-gnu:/usr/lib:$LD_LIBRARY_PATH"
export JAVA_LIBRARY_PATH="/tmp/javacpp-cache:/usr/lib/x86_64-linux-gnu:/usr/lib"
export JAVACPP_CACHE_DIR="/tmp/javacpp-cache"
export JAVACPP_VERBOSE=1

# Crear un programa Java simple para forzar la carga
cat > /tmp/ForceJNILoad.java << 'EOF'
import java.io.File;
import java.lang.reflect.Method;

public class ForceJNILoad {
    public static void main(String[] args) {
        try {
            // Configurar java.library.path
            System.setProperty("java.library.path", 
                "/tmp/javacpp-cache" + File.pathSeparator + 
                "/usr/lib/x86_64-linux-gnu" + File.pathSeparator + 
                "/usr/lib");
            
            // Forzar recarga del ClassLoader
            Method methodSysPath = ClassLoader.class.getDeclaredMethod("sys_paths", String.class);
            methodSysPath.setAccessible(true);
            methodSysPath.invoke(null, (Object) null);
            
            System.out.println("✅ java.library.path configurado");
            
            // Intentar cargar librerías JNI
            try {
                System.loadLibrary("jnileptonica");
                System.out.println("✅ jnileptonica cargada");
            } catch (UnsatisfiedLinkError e) {
                System.out.println("⚠️ jnileptonica no encontrada: " + e.getMessage());
            }
            
            try {
                System.loadLibrary("jnioffice");
                System.out.println("✅ jnioffice cargada");
            } catch (UnsatisfiedLinkError e) {
                System.out.println("⚠️ jnioffice no encontrada: " + e.getMessage());
            }
            
            try {
                System.loadLibrary("jniopencv");
                System.out.println("✅ jniopencv cargada");
            } catch (UnsatisfiedLinkError e) {
                System.out.println("⚠️ jniopencv no encontrada: " + e.getMessage());
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Compilar y ejecutar
echo "📝 Compilando programa de carga JNI..."
javac /tmp/ForceJNILoad.java

if [ $? -eq 0 ]; then
    echo "✅ Compilación exitosa"
    echo "🚀 Ejecutando carga JNI..."
    java -cp /tmp ForceJNILoad
else
    echo "❌ Error en compilación"
fi

# Limpiar archivos temporales
rm -f /tmp/ForceJNILoad.java /tmp/ForceJNILoad.class

echo "✅ Carga JNI completada"
