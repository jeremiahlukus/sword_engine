FROM ubuntu:22.04

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    libclucene-dev \
    libcurl4-openssl-dev \
    libsword-dev \
    sword-text-kjv \
    python3 \
    python3-pip \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /sword

# Copy SWORD Engine source
COPY . .

# Configure and build
RUN ./configure \
    && make \
    && make install \
    && ldconfig

# Install Python bindings for SWORD
RUN apt-get update && \
    apt-get install -y python3-sword && \
    pip3 install flask

# Create a directory for SWORD modules
RUN mkdir -p /usr/local/share/sword/modules/texts/ztext/recver && \
    mkdir -p /usr/local/share/sword/mods.d

# Copy the RecVer module data and configuration
COPY RecVer/modules/texts/ztext/recver/* /usr/local/share/sword/modules/texts/ztext/recver/
COPY RecVer/mods.d/recver.conf /usr/local/share/sword/mods.d/

# Copy the API server script
COPY api_server.py /usr/local/bin/
RUN chmod +x /usr/local/bin/api_server.py

# Expose the API port
EXPOSE 8081

# Set the entrypoint
CMD ["python3", "/usr/local/bin/api_server.py"] 