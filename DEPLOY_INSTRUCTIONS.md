# 🚀 Instrucciones de Despliegue - Servicio Audiveris

## ✅ Estado Actual
El servicio se ha simplificado para funcionar exactamente igual que en local.

## 🔧 Cambios Realizados

### 1. **Index.js Simplificado**
- Reemplazado con la versión que funcionaba en local
- Eliminados scripts complejos y configuraciones innecesarias
- Comando directo: `java -cp "lib/*" Audiveris -batch input -export -output output`

### 2. **Dockerfile Optimizado**
- Añadidas librerías nativas necesarias para Java:
  - `libfreetype6` - Para manejo de fuentes
  - `libfontconfig1` - Configuración de fuentes
  - `libxrender1`, `libxtst6`, `libxi6` - Librerías gráficas
  - Y otras dependencias necesarias

### 3. **Package.json Simplificado**
- Eliminado el script `prestart` problemático
- Solo `npm start` directo

## 🎯 Próximos Pasos

### 1. **Commit y Push**
```bash
git add .
git commit -m "fix: corregir dependencias nativas Java para Audiveris"
git push origin main
```

### 2. **Render Automático**
- Render detectará automáticamente los cambios
- Reconstruirá la imagen con las nuevas dependencias
- El servicio debería funcionar correctamente

## 🐛 Problema Solucionado

**Error anterior:**
```
java.lang.UnsatisfiedLinkError: libfreetype.so.6: cannot open shared object file
```

**Solución:**
- Añadidas todas las librerías nativas necesarias en el Dockerfile
- El servicio ahora debería procesar PDFs correctamente

## 🔍 Verificación

Después del despliegue, prueba con un PDF simple para verificar que:
1. ✅ El servicio responde en `https://audiveris-service.onrender.com`
2. ✅ Puede procesar PDFs sin errores de librerías nativas
3. ✅ Devuelve archivos MusicXML correctamente

## 📞 Si Persisten Problemas

Si aún hay errores, revisar:
1. Logs de Render para ver errores específicos
2. Verificar que el directorio `audiveris-5.4` esté completo
3. Confirmar que `audiveris.jar` existe en `audiveris-5.4/lib/`
