FROM openjdk:21-jdk-slim

# Instalar Node.js 20
RUN apt-get update && apt-get install -y curl gnupg ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias básicas y librerías nativas necesarias para Java
RUN apt-get update && apt-get install -y \
    wget unzip curl ca-certificates \
    libfreetype6 libfontconfig1 \
    libxrender1 libxtst6 libxi6 \
    libxrandr2 libxss1 libgconf-2-4 \
    libasound2 libpangocairo-1.0-0 \
    libatk1.0-0 libcairo-gobject2 \
    libgtk-3-0 libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV JAVA_HOME=/usr/local/openjdk-21
ENV PATH="$JAVA_HOME/bin:$PATH"

# Directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json e instalar dependencias
COPY package*.json ./
RUN npm install --production

# Copiar el resto de la aplicación
COPY . .

# Exponer puerto
EXPOSE 4000

# Comando simple - igual que en local
CMD ["npm", "start"]
