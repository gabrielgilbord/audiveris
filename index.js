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

if (!fs.existsSync(INPUT_DIR)) {
  fs.mkdirSync(INPUT_DIR, { recursive: true });
}

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, INPUT_DIR);
  },
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
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten archivos PDF.'));
    }
  },
  limits: {
    fileSize: 25 * 1024 * 1024 // 25 MB
  }
});

app.use(cors());
app.use(express.json());
app.use('/outputs', express.static(OUTPUT_DIR));

const runAudiveris = (inputPath) => {
  return new Promise((resolve, reject) => {
    const libPath = path.join(AUDIVERIS_DIR, 'lib', '*');
    const command = `java -cp "${libPath}" Audiveris -batch "${inputPath}" -export -output "${OUTPUT_DIR}"`;
    console.log('> Comando Audiveris:', command);

    const child = exec(command, { cwd: AUDIVERIS_DIR, shell: true });

    child.stdout.on('data', (data) => {
      console.log(`[AUDIVERIS] ${data}`);
    });

    child.stderr.on('data', (data) => {
      console.error(`[AUDIVERIS][ERR] ${data}`);
    });

    child.on('error', (error) => {
      reject(error);
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Audiveris finalizó con código ${code}`));
      }
    });
  });
};

const findOutputFile = (inputFile) => {
  const baseName = path.basename(inputFile, path.extname(inputFile));
  const possibleExtensions = ['.xml', '.musicxml', '.mxl'];

  // Buscar archivos que coincidan con el nombre base
  const matchingFiles = fs
    .readdirSync(OUTPUT_DIR)
    .filter((file) => {
      const fileBaseName = path.basename(file, path.extname(file));
      return fileBaseName === baseName && possibleExtensions.includes(path.extname(file).toLowerCase());
    })
    .map((file) => path.join(OUTPUT_DIR, file));

  if (matchingFiles.length === 0) {
    // Buscar en subdirectorios
    const subDir = path.join(OUTPUT_DIR, baseName);
    if (fs.existsSync(subDir) && fs.statSync(subDir).isDirectory()) {
      const files = fs.readdirSync(subDir);
      const match = files.find((file) => possibleExtensions.includes(path.extname(file).toLowerCase()));
      if (match) {
        return path.join(subDir, match);
      }
    }
    return null;
  }

  // Si hay múltiples archivos, devolver el de mayor tamaño (el completo)
  if (matchingFiles.length > 1) {
    matchingFiles.sort((a, b) => fs.statSync(b).size - fs.statSync(a).size);
    console.log(`> Encontrados ${matchingFiles.length} archivos, seleccionando el más pesado:`, matchingFiles[0]);
  }

  return matchingFiles[0];
};

let isProcessing = false;
const queue = [];

const processQueue = async () => {
  if (isProcessing || queue.length === 0) {
    return;
  }
  isProcessing = true;

  const { req, res } = queue.shift();

  try {
    if (!req.file) {
      res.status(400).json({ message: 'No se recibió ningún archivo PDF.' });
      return;
    }

    const pdfPath = req.file.path;
    console.log('> Ejecutando Audiveris con', pdfPath);
    await runAudiveris(pdfPath);
    console.log('> Audiveris finalizado');

    const musicXmlPath = findOutputFile(req.file.filename);

    if (!musicXmlPath) {
      console.error('> No se encontró salida para', req.file.filename);
      res.status(500).json({
        message: 'No se encontró el archivo MusicXML generado.',
        detail: 'Revisa los logs de Audiveris para más información.'
      });
      return;
    }

    const relativePath = path.relative(OUTPUT_DIR, musicXmlPath).replace(/\\/g, '/');

    console.log('> MusicXML generado', musicXmlPath);

    if (res.headersSent) {
      console.warn('> La respuesta ya se envió, se descarta el resultado');
      return;
    }

    res.json({
      message: 'Conversión completada',
      pdf: {
        originalName: req.file.originalname,
        storedName: req.file.filename
      },
      result: {
        fileName: path.basename(musicXmlPath),
        url: `/outputs/${relativePath}`
      }
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

app.post('/convert', upload.single('pdf'), (req, res) => {
  console.log('> /convert recibido', {
    file: req.file?.originalname,
    size: req.file?.size,
    stored: req.file?.filename
  });

  queue.push({ req, res });
  processQueue();
});

app.get('/health', (_req, res) => {
  const javaInstalled = !!process.env.JAVA_HOME || process.platform === 'win32';
  res.json({
    status: 'ok',
    audiverisPath: AUDIVERIS_DIR,
    javaDetected: javaInstalled
  });
});

app.listen(PORT, () => {
  console.log(`Audiveris OMR service running on http://localhost:${PORT}`);
});


