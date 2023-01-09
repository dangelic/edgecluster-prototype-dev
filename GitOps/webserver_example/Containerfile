FROM docker.io/library/node:14-alpine AS node

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3555

CMD ["node", "server.js"]