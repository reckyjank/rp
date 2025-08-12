FROM runpod/worker-comfyui:5.3.0-base

RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

RUN comfy-node-install https://github.com/cubiq/ComfyUI_essentials@9d9f4bedfc9f0321c19faf71855e228c93bd0dc9 && \
    comfy-node-install https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite@8e4d79471bf1952154768e8435a9300077b534fa

# Map ComfyUI models directory to Runpod network volume to avoid copying large model files
RUN mkdir -p /runpod-volume/models /workspace/ComfyUI && \
    rm -rf /workspace/ComfyUI/models && \
    ln -s /runpod-volume/models /workspace/ComfyUI/models
