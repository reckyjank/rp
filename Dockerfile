FROM nvidia/cuda:12.6.2-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python and system dependencies
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

# Set the environment variable for Runpod
ENV RUNPOD_HANDLER=main

# Set the Hugging Face Token as an environment variable in Docker
# You will replace `your_hugging_face_token` with the actual token during deployment (could be passed in the Runpod config).
ENV HF_TOKEN=your_hugging_face_token

CMD [ "python3", "-u", "main.py" ]
