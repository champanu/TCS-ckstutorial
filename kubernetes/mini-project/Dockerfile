FROM node:20-alpine

WORKDIR /usr/src/app

# Copy package files first (if you later add package.json)
COPY package*.json ./

RUN npm install

# Copy application code
COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
