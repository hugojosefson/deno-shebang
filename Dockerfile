FROM debian:11-slim
LABEL maintainer="Hugo Josefson <hugo@josefson.org> https://www.hugojosefson.com/"

RUN apt-get update && apt-get -y install curl unzip make docker.io

WORKDIR /app
COPY . .
