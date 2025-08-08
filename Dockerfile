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

# Bake the FLUX model into the image to avoid downloads at cold start
ARG HF_TOKEN
ENV HF_HOME=/root/.cache/huggingface
# Expose HF_TOKEN to this build step only, then clear it
ENV HF_TOKEN=${HF_TOKEN}
RUN mkdir -p /models/FLUX.1-dev && \
    python - << 'PY'
import os
from diffusers import FluxPipeline
pipe = FluxPipeline.from_pretrained(
    "black-forest-labs/FLUX.1-dev",
    token=os.environ.get("HF_TOKEN"),
)
pipe.save_pretrained("/models/FLUX.1-dev")
print("Saved FLUX.1-dev to /models/FLUX.1-dev")
PY
ENV HF_TOKEN=

COPY . .
ENV RUNPOD_HANDLER=main
ENV FLUX_MODEL_DIR=/models/FLUX.1-dev
CMD ["python", "-u", "main.py"]
