# Audiveris OMR Microservice

Servicio Express independiente que envuelve Audiveris (motor de OCR musical) para convertir PDFs de partituras a MusicXML.

## Requisitos

- Java 17 u 11 instalado y disponible en `PATH` o `JAVA_HOME`.
- Dependencias nativas incluidas con la distribución de Audiveris 5.4 (copiadas en `audiveris-5.4/`).
- Node.js 18+

## Instalación

```bash
cd audiveris-service
npm install
# Asegúrate de tener la carpeta audiveris-5.4/ con bin/ y lib/
npm start
```

Por defecto el servicio escucha en `http://localhost:4000`.

## Endpoints

### `POST /convert`

- `multipart/form-data`, campo `pdf`: archivo PDF de la partitura.
- Ejecuta Audiveris en modo batch y genera un MusicXML.
- Respuesta JSON:

```json
{
  "message": "Conversión completada",
  "pdf": {
    "originalName": "Partitura.pdf",
    "storedName": "Partitura_1696012345678.pdf"
  },
  "result": {
    "fileName": "Partitura_1696012345678.mxl",
    "url": "/outputs/Partitura_1696012345678.mxl"
  }
}
```

### `GET /health`

Devuelve información básica sobre el estado del servicio.

## Integración con Musync

En el proyecto principal, define la URL del servicio en un archivo `.env.local`:

```
NEXT_PUBLIC_AUDIVERIS_URL=http://localhost:4000/convert
```

El componente `AudiverisProcessorClient` consumirá este endpoint y transformará el MusicXML resultante a `ScoreData` para el reproductor.

## Despliegue sugerido

Para entornos gratuitos se recomienda usar una máquina virtual con Java (por ejemplo, Azure Free Tier, Fly.io, Render free tier). El servicio **no** funciona en plataformas serverless estrictas (Netlify, Vercel) por los requisitos de Java y binarios nativos.



