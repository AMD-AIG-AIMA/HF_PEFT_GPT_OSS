#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PYTHON=python3  # adjust if you need a specific python

# Upgrade pip first
"$PYTHON" -m pip install --upgrade pip

# Uninstall any existing transformers
"$PYTHON" -m pip uninstall -y transformers || true

cd ../

# Remove any existing clone to ensure a fresh git clone
rm -rf transformers

# Clone the specific Transformers release and install it
git clone https://github.com/huggingface/transformers.git
cd transformers
"$PYTHON" -m pip install -e .
cd ../

# Install PEFT
"$PYTHON" -m pip install peft

echo "All Packages Installed for MI355!"
