import runpod
import subprocess
import json
import os
import base64
from io import BytesIO
import torch
from diffusers import FluxPipeline
from datetime import datetime


def handler(event):
    device = "cuda" if torch.cuda.is_available() else "cpu"
    dtype = torch.bfloat16 if device == "cuda" else torch.float32

    # Always load from a baked local model directory to avoid any cold-start downloads
    local_model_dir = os.environ.get("FLUX_MODEL_DIR", "/models/FLUX.1-dev")
    pipe = FluxPipeline.from_pretrained(
        local_model_dir,
        torch_dtype=dtype,
        local_files_only=True,
    )

    input_payload = event.get("input", {})

    seed = input_payload.get("seed")
    generator = None
    if seed is not None:
        generator = torch.Generator(device=device).manual_seed(seed)

    call_kwargs = {
        "prompt": input_payload["prompt"],
        "height": input_payload["height"],
        "width": input_payload["width"],
        "num_inference_steps": input_payload["steps"],
        "guidance_scale": input_payload["guidance"],
        "generator": generator,
    }

    # Optional arguments
    neg = input_payload.get("negativePrompt")
    if neg is not None:
        call_kwargs["negative_prompt"] = neg

    max_seq_len = input_payload.get("maxSequenceLength")
    if max_seq_len is not None:
        call_kwargs["max_sequence_length"] = max_seq_len

    image = pipe(**call_kwargs).images[0]

    buffer = BytesIO()
    image.save(buffer, format="PNG")
    buffer.seek(0)
    image_base64 = base64.b64encode(buffer.getvalue()).decode("utf-8")

    return image_base64


if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
