# Usar la imagen completa de Node.js para que npm esté disponible
FROM node:20

# Instalar dependencias, OpenJDK 21 y Tesseract OCR
RUN apt-get update && apt-get install -y \
    curl gnupg unzip tesseract-ocr tesseract-ocr-eng && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y temurin-21-jdk && \
    rm -rf /var/lib/apt/lists/*

# Variables de entorno de Java
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Optional: indicar la ruta de los datos de Tesseract
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json e instalar dependencias
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Exponer el puerto de la app
EXPOSE 4000

# Comando por defecto
CMD ["npm", "start"]