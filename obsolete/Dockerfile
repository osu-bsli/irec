FROM ubuntu:26.04
ENV LANG=C.UTF-8

# Install apt packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y openjdk-17-jdk maven build-essential cmake ninja-build python3-full python3-pip git libsdl3-dev
RUN rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/