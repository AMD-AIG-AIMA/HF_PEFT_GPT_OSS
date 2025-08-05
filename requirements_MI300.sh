#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
# Change this if you want a different python executable
PYTHON=python3

# Ensure pip is up to date
"$PYTHON" -m pip install --upgrade pip

# Uninstall existing transformers if any
"$PYTHON" -m pip uninstall -y transformers || true

cd ../

# Remove any existing clone to ensure a fresh git clone
rm -rf transformers

# Clone the specific Transformers release and install it
git clone https://github.com/huggingface/transformers.git
cd transformers
"$PYTHON" -m pip install -e .
cd ../

# Upgrade accelerate
"$PYTHON" -m pip install --upgrade accelerate

echo "All Packages Installed for MI300!"
