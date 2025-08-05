# OpenAI MoE (GPT-OSS) Docker Setup for AMD MI300 & MI355

This repository provides step-by-step instructions to set up OpenAI Mixture-of-Experts (MoE) OSS model functionality inside a Docker container on AMD MI300 and MI355 GPUs using ROCm and PyTorch.

---

This demo leverages [Hugging Face’s PEFT LoRA](https://huggingface.co/docs/peft/en/package_reference/lora) to efficiently fine-tune an OpenAI 20 billion-parameter MoE transformer—with 24 alternating sliding-window/full-attention layers and 32 experts.

Training is performed via Accelerate with FSDP in bfloat16 (gradient checkpointing enabled) on the 200 K-example `HuggingFaceH4/ultrachat_200k` chat dataset.

UltraChat 200k is a heavily filtered, 200 000-example subset of the original UltraChat pool (≈ 1.4 million ChatGPT-generated multi-turn dialogues). To create it, examples were selected for supervised fine-tuning, true-casing was applied to fix capitalization errors, and any assistant replies that merely disclaim opinions or emotions were removed.

**Supported Models:**
1. `gpt-oss-120b` — for production, general purpose, high reasoning use cases that fits into a single MI300 GPU (117B parameters with 5.1B active parameters)
2. `gpt-oss-20b` — for lower latency, and local or specialized use cases (21B parameters with 3.6B active parameters)

The dataset is stored in Parquet format with each entry using the following schema:

- `prompt`
- `prompt_id`
- `messages`: a list of `{ role, content }` pairs

<ins>This Flowchart Illustrates Fine-tuning Pipeline for OpenAI MoE Model using UltraChat 200 with Hugging Face Ecosystem.</ins>

<p align="center">
<img width="798" height="346" alt="arch_openai (1)" src="https://github.com/user-attachments/assets/0cd4f8ef-a88c-4a64-a226-d1ea0514e59f" />
</p>


---


## Prerequisites

- Docker installed and working.
- ROCm-compatible system with MI300X or MI355X GPUs.
- Hugging Face account with a valid token.
- Sufficient disk space for model checkpoints (20B model).
- Network access to clone repositories and download from Hugging Face.

## Step 1. Pull the PyTorch Docker Container

### For MI300X
```bash
docker pull rocm/pytorch-training:v25.6
```

### For MI355X
```bash
docker pull rocm/7.0-preview:rocm7.0_preview_pytorch_training_mi35X_alpha
```

## Step 2. Launch / Run the Docker Container

> Replace "/home/USERNAME/" with your actual host path to mount into the container at "/workspace/".  
> Replace `YOUR_DOCKER_NAME` with a name you choose.

### For MI300X
```bash
docker run -it \
  --device /dev/dri \
  --device /dev/kfd \
  --network host \
  --ipc host \
  --group-add video \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --privileged \
  -v /home/USERNAME/:/workspace/ \
  --name YOUR_DOCKER_NAME \
  rocm/pytorch-training:v25.6
```

### For MI355X
```bash
docker run -it \
  --device /dev/dri \
  --device /dev/kfd \
  --network host \
  --ipc host \
  --group-add video \
  --cap-add SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --privileged \
  -v /home/USERNAME/:/workspace/ \
  --name YOUR_DOCKER_NAME \
  rocm/7.0-preview:rocm7.0_preview_pytorch_training_mi35X_alpha
```

## Step 3. Download the 20B MoE Model Checkpoint

All commands below apply to both MI300X and MI355X.

> ⚠️ **Note on Transformers:**
> Starting from version 4.55.0.dev0 of the Transformers library, built-in OpenAI Mixture of Experts (MoE) support is now available.


```bash
# Log in to Hugging Face
huggingface-cli login
# (Enter your HF token when prompted)

# Download the checkpoint
huggingface-cli download HUGGING_FACE_MODEL_DOWNLOAD_LINK --local-dir ./models/MODEL_NAME

#For example, to dowbload 20B model
huggingface-cli download openai/gpt-oss-20b --local-dir ./models/gpt-oss-20b

#For example, to dowbload 120B model
huggingface-cli download openai/gpt-oss-120b --local-dir ./models/gpt-oss-120b
```

- You can rename `MODEL_NAME` to whatever you prefer.
- You need to use official OpenAI mode link instead of `HUGGING_FACE_MODEL_DOWNLOAD_LINK`.
- Ensure the `models/MODEL_NAME` directory exists or will be created.

## Step 4. Clone PEFT Setup, Upgrade Dependencies, and Run LoRA Script

```bash
cd /workspace/

# Clone the repository
git clone https://github.com/kailashg26/HF_PEFT_GPT_OSS.git
cd HF_PEFT_GPT_OSS

# For MI300X, upgrade required libraries
bash requirements_MI300.sh

# For MI355X, upgrade required libraries
bash requirements_MI355.sh

# Run the LoRA fine-tuning script
bash run_peft_lora_openai.sh
```


**Important:**  
Edit `run_peft_lora_openai.sh` before running and set the `model_name_or_path` variable to the path of your downloaded checkpoint (e.g., `models/MODEL_NAME`).

By default the script runs on a single node with eight GPUs. Modify the script parameters if you need multi-node, different GPU counts, batch sizes, etc.

## Troubleshooting

- **Docker permission errors**: Ensure your user has access to `/dev/kfd` and is part of the `video` group if required.
- **ROCm device not visible**: Verify ROCm driver installation and that the container has the necessary devices (`/dev/kfd`, `/dev/dri`) mounted.
- **Hugging Face authentication fails**: Confirm your token is valid and has the appropriate read access to the model repository.
- **Dependency/installation issues**: Re-run the appropriate `requirements_*.sh` and inspect their output for missing packages or version conflicts.


## Cleanup

To stop and remove the container:

```bash
docker stop YOUR_DOCKER_NAME
docker rm YOUR_DOCKER_NAME
```

To remove pulled images if needed:

```bash
docker image rm rocm/pytorch-training:v25.6
docker image rm rocm/7.0-preview:rocm7.0_preview_pytorch_training_mi35X_alpha
```

---

## Future Updates

Once OpenAI releases official support for GPT OSS MoE blocks in Hugging Face Transformers:

- You can continue using any Transformers version ≥ 4.53.0 without manual patches.
- The native `openai_moe` architecture and `OpenAIMoeForCausalLM` classes will be available by default.
