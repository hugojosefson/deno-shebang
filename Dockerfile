FROM debian:13-slim
LABEL maintainer="Hugo Josefson <hugo@josefson.org> https://www.hugojosefson.com/"

RUN apt-get update && apt-get -y install sudo make docker.io

WORKDIR /app
COPY . .
