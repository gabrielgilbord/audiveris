# Usar la imagen oficial de Node.js con npm
FROM node:20

# Instalar dependencias, OpenJDK 21, Tesseract OCR y librerías nativas
RUN apt-get update && apt-get install -y \
    curl gnupg unzip \
    tesseract-ocr tesseract-ocr-eng \
    libleptonica-dev libtesseract-dev pkg-config \
    && curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json y hacer instalación
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto de la app
EXPOSE 4000

# Comando por defecto
CMD ["npm", "start"]
