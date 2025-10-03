'use strict';

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');

const app = express();
const PORT = process.env.PORT || 4000;

const BASE_DIR = __dirname;
const AUDIVERIS_DIR = path.resolve(BASE_DIR, 'audiveris-5.4');
const INPUT_DIR = path.resolve(BASE_DIR, 'uploads', 'input');
const OUTPUT_DIR = path.resolve(BASE_DIR, 'uploads', 'output');

// Crear carpetas si no existen
if (!fs.existsSync(INPUT_DIR)) fs.mkdirSync(INPUT_DIR, { recursive: true });
if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

// Configuración de multer
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, INPUT_DIR),
  filename: (_req, file, cb) => {
    const safeName = file.originalname
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-zA-Z0-9._-]/g, '_')
      .replace(/_+/g, '_');
    const timestamp = Date.now();
    const ext = path.extname(safeName) || '.pdf';
    const base = path.basename(safeName, ext);
    cb(null, `${base}_${timestamp}${ext}`);
  }
});

const upload = multer({
  storage,
  fileFilter: (_req, file, cb) => {
    if (file.mimetype === 'application/pdf') cb(null, true);
    else cb(new Error('Solo se permiten archivos PDF.'));
  },
  limits: { fileSize: 25 * 1024 * 1024 } // 25 MB
});

app.use(cors());
app.use(express.json());
app.use('/outputs', express.static(OUTPUT_DIR));

// Verificar librerías nativas al inicio
const checkNativeLibraries = () => {
  console.log('🔍 Verificando librerías nativas...');
  console.log('LD_LIBRARY_PATH:', process.env.LD_LIBRARY_PATH);
  console.log('JAVA_HOME:', process.env.JAVA_HOME);
  console.log('TESSDATA_PREFIX:', process.env.TESSDATA_PREFIX);
  
  // Verificar que las librerías estén disponibles
  const fs = require('fs');
  const libPaths = [
    '/usr/lib/x86_64-linux-gnu/liblept.so.5.0.4',
    '/usr/lib/x86_64-linux-gnu/libtesseract.so.5.0.3',
    '/usr/lib/liblept.so',
    '/usr/lib/libtesseract.so'
  ];
  
  libPaths.forEach(libPath => {
    if (fs.existsSync(libPath)) {
      console.log(`✅ Encontrada: ${libPath}`);
    } else {
      console.log(`❌ No encontrada: ${libPath}`);
    }
  });
};

// Ejecutar verificación al inicio
checkNativeLibraries();

// Función para ejecutar Audiveris
const runAudiveris = (inputPath) => {
  return new Promise((resolve, reject) => {
    // Usar el script que usa librerías del sistema
    const command = `./run-audiveris-system.sh "${inputPath}" "${OUTPUT_DIR}"`;
    console.log('> Ejecutando Audiveris con librerías del sistema');

    const child = exec(command, { cwd: '/app', shell: true });

    child.stdout.on('data', (data) => console.log(`[AUDIVERIS] ${data}`));
    child.stderr.on('data', (data) => console.error(`[AUDIVERIS][ERR] ${data}`));

    child.on('error', (error) => reject(error));
    child.on('close', (code) => {
      code === 0 ? resolve() : reject(new Error(`Audiveris finalizó con código ${code}`));
    });
  });
};

// Buscar archivo de salida
const findOutputFile = (inputFile) => {
  const baseName = path.basename(inputFile, path.extname(inputFile));
  const possibleExtensions = ['.xml', '.musicxml', '.mxl'];

  let matchingFiles = fs.readdirSync(OUTPUT_DIR)
    .filter(file => path.basename(file, path.extname(file)) === baseName && possibleExtensions.includes(path.extname(file).toLowerCase()))
    .map(file => path.join(OUTPUT_DIR, file));

  if (matchingFiles.length === 0) {
    const subDir = path.join(OUTPUT_DIR, baseName);
    if (fs.existsSync(subDir) && fs.statSync(subDir).isDirectory()) {
      const match = fs.readdirSync(subDir).find(file => possibleExtensions.includes(path.extname(file).toLowerCase()));
      if (match) return path.join(subDir, match);
    }
    return null;
  }

  if (matchingFiles.length > 1) {
    matchingFiles.sort((a, b) => fs.statSync(b).size - fs.statSync(a).size);
    console.log(`> Encontrados ${matchingFiles.length} archivos, seleccionando el más pesado:`, matchingFiles[0]);
  }

  return matchingFiles[0];
};

// Cola de procesamiento
let isProcessing = false;
const queue = [];

const processQueue = async () => {
  if (isProcessing || queue.length === 0) return;
  isProcessing = true;

  const { req, res } = queue.shift();

  try {
    if (!req.file) return res.status(400).json({ message: 'No se recibió ningún archivo PDF.' });

    const pdfPath = req.file.path;
    console.log('> Ejecutando Audiveris con', pdfPath);
    await runAudiveris(pdfPath);
    console.log('> Audiveris finalizado');

    const musicXmlPath = findOutputFile(req.file.filename);

    if (!musicXmlPath) {
      console.error('> No se encontró salida para', req.file.filename);
      return res.status(500).json({ message: 'No se encontró el archivo MusicXML generado.', detail: 'Revisa los logs de Audiveris.' });
    }

    const relativePath = path.relative(OUTPUT_DIR, musicXmlPath).replace(/\\/g, '/');
    console.log('> MusicXML generado', musicXmlPath);

    res.json({
      message: 'Conversión completada',
      pdf: { originalName: req.file.originalname, storedName: req.file.filename },
      result: { fileName: path.basename(musicXmlPath), url: `/outputs/${relativePath}` }
    });
    console.log('> Respuesta JSON enviada');
  } catch (error) {
    console.error('Error durante la conversión:', error);
    res.status(500).json({ message: 'Error procesando el PDF', detail: error.message });
  } finally {
    isProcessing = false;
    processQueue();
  }
};

// Endpoint de conversión
app.post('/convert', upload.single('pdf'), (req, res) => {
  console.log('> /convert recibido', { file: req.file?.originalname, size: req.file?.size, stored: req.file?.filename });
  queue.push({ req, res });
  processQueue();
});

// Health check
app.get('/health', (_req, res) => {
  const javaInstalled = !!process.env.JAVA_HOME || process.platform === 'win32';
  res.json({ status: 'ok', audiverisPath: AUDIVERIS_DIR, javaDetected: javaInstalled });
});

// Manejo de shutdown para Render
const shutdown = () => {
  console.log('> Recibida señal de shutdown, cerrando servidor...');
  process.exit(0);
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// Arrancar servidor
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on ${PORT}`));
