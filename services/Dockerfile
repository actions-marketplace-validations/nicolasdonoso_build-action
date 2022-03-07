FROM 743726466037.dkr.ecr.us-west-2.amazonaws.com/node-alpine
WORKDIR /usr/src/app
ARG NPM_TOKEN
COPY .npmrc .npmrc
COPY package*.json ./
RUN apk add make gcc g++ python && \
  npm i && \
  apk del make gcc g++ python
RUN rm -f .npmrc
COPY . .

EXPOSE 8080

CMD [ "app.js" ]