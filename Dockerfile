FROM openjdk:21-jdk-slim

# Instalar Node.js 20
RUN apt-get update && apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias del sistema y librerías nativas
RUN apt-get update && apt-get install -y \
    wget unzip build-essential curl \
    tesseract-ocr tesseract-ocr-eng tesseract-ocr-spa \
    libtesseract-dev libleptonica-dev \
    libopencv-dev libavcodec-dev libavformat-dev \
    libswscale-dev libv4l-dev libxvidcore-dev \
    libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    libatlas-base-dev gfortran \
    libfreetype6-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV JAVA_HOME=/usr/local/openjdk-21
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/
ENV JAVACPP_PLATFORM=linux-x86_64
ENV JAVACPP_VERBOSE=1
ENV JAVACPP_CACHE_DIR=/tmp/javacpp-cache
ENV LD_LIBRARY_PATH="/tmp/javacpp-cache:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json e instalar dependencias
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Hacer ejecutables los scripts
RUN chmod +x /app/init-libs.sh /app/run-audiveris.sh /app/run-audiveris-system.sh /app/preload-javacpp.sh /app/download-javacpp-libs.sh /app/download-manual-javacpp.sh

# Crear directorio de cache para JavaCPP
RUN mkdir -p /tmp/javacpp-cache

# Exponer puerto
EXPOSE 4000

# Comando por defecto con descarga manual de JavaCPP
CMD ["sh", "-c", "./init-libs.sh && ./download-manual-javacpp.sh && npm start"]
