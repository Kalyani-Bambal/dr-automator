FROM node:22-alpine

WORKDIR /app

ENV PORT=3000

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm","start"]