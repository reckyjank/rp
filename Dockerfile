FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip git ffmpeg \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY requirements.txt .

# Install CUDA build of torch first, then the rest
RUN pip install --upgrade pip && \
    pip install --extra-index-url https://download.pytorch.org/whl/cu121 \
      torch==2.4.0 torchvision==0.19.0 && \
    pip install -r requirements.txt

COPY . .
ENV RUNPOD_HANDLER=main
CMD ["python", "-u", "main.py"]
