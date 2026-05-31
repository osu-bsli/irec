FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y openjdk-17-jdk maven && rm -rf /var/lib/apt/lists/*
WORKDIR /irec
COPY . .

WORKDIR /irec/openrocket-plugin-airbrakes
RUN chmod +x ./gradlew
RUN ./gradlew jar