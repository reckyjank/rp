FROM nvidia/cuda:12.6.2-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python, Node.js and system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    git ffmpeg build-essential cmake libssl-dev \
    curl wget \
    libcudnn8 libcudnn8-dev \
    && rm -rf /var/lib/apt/lists/*

# Create python symlink
RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt

# Copy application code
COPY . .

ENV RUNPOD_HANDLER=main

CMD [ "python3", "-u", "main.py" ]
