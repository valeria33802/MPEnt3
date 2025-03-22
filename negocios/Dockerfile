FROM node:20 
#antes 14
WORKDIR /app

# Copiamos package.json, package-lock.json e instalamos dependencias
COPY package*.json ./
RUN npm install

# Copiamos el resto del código
COPY . .

# Copiamos el script wait-for-it.sh (ajusta la ruta según dónde lo guardaste)
COPY ../docker/wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Exponemos el puerto
EXPOSE 3000

# Ejecutamos wait-for-it antes de iniciar Node
# Sustituye "mysql:3306" por el host:puerto donde corre MySQL en la red de Docker
CMD ["/wait-for-it.sh", "mysql:3306",  "-t", "50", "--", "node", "server.js"]
