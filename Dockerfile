FROM node:20

# Instalar dependencias, OpenJDK 21, Tesseract OCR y librerías nativas
RUN apt-get update && apt-get install -y \
    curl gnupg unzip \
    tesseract-ocr tesseract-ocr-eng \
    libleptonica-dev libtesseract-dev pkg-config \
    libpng-dev libjpeg-dev \
    && curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y temurin-21-jdk \
    # Crear symlinks para que JavaCPP encuentre las libs
    && ln -s /usr/lib/x86_64-linux-gnu/liblept.so /usr/lib/x86_64-linux-gnu/libjnileptonica.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libtesseract.so /usr/lib/x86_64-linux-gnu/libjnitesseract.so \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV TESSDATA_PREFIX=/usr/share/tesseract-ocr/5/tessdata/
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json e instalar dependencias
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto
EXPOSE 4000

# Comando por defecto
CMD ["npm", "start"]
