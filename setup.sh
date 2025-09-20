#!/bin/bash

set -euo pipefail

export HF_HUB_DISABLE_PROGRESS_BARS=1
export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32

# Base deps
pip install -U pip ninja "huggingface_hub[cli]"

# SageAttention
git clone https://github.com/thu-ml/SageAttention.git || true
cd SageAttention
python setup.py install
cd ..

# ComfyUI + Manager
git clone https://github.com/comfyanonymous/ComfyUI.git || true
cd ComfyUI
pip install -r requirements.txt
cd custom_nodes
[ ! -d "ComfyUI-Manager" ] && git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
cd ComfyUI-Manager && pip install -r requirements.txt
cd ../..

# Models
cd models/diffusion_models
hf download Kijai/WanVideo_comfy InfiniteTalk/Wan2_1-InfiniTetalk-Single_fp16.safetensors --local-dir .
#repeat for whatever models you need

cd /workspace/ComfyUI/custom_nodes
[ ! -d "ComfyUI-VideoHelperSuite" ] && git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite && pip install -r requirements.txt
cd ..
#repeat for whatever custom nodes you need

# Start ComfyUI
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --use-sage-attention