FROM node:20

# Instalar dependencias completas + OpenJDK 21 + Tesseract OCR + librerías nativas
RUN apt-get update && apt-get install -y \
    curl gnupg unzip wget build-essential \
    tesseract-ocr tesseract-ocr-eng tesseract-ocr-spa \
    libtesseract-dev libleptonica-dev \
    libopencv-dev libavcodec-dev libavformat-dev \
    libswscale-dev libv4l-dev libxvidcore-dev \
    libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    libatlas-base-dev gfortran \
    libfreetype6-dev zlib1g-dev \
    && curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/
ENV JAVACPP_PLATFORM=linux-x86_64
ENV JAVACPP_VERBOSE=1
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json e instalar dependencias
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Hacer ejecutable el script de inicialización
RUN chmod +x /app/init-libs.sh

# Exponer puerto
EXPOSE 4000

# Comando por defecto con inicialización de librerías
CMD ["sh", "-c", "./init-libs.sh && npm start"]
