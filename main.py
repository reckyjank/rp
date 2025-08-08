import runpod
import subprocess
import json

def handler(event):
    type = event["input"]["type"]
    return type



if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
