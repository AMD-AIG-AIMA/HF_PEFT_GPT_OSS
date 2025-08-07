#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
PYTHON=python3  # adjust if you need a specific python

# Upgrade pip first
"$PYTHON" -m pip install --upgrade pip

# Ensure pip is up to date
"$PYTHON" -m pip install --upgrade pip

# Uninstall any existing versions
"$PYTHON" -m pip uninstall -y transformers accelerate

# Install the exact versions you want
"$PYTHON" -m pip install transformers==4.55.0 accelerate==1.9.0

# Install PEFT
"$PYTHON" -m pip install peft

echo "All Packages Installed for MI355!"
