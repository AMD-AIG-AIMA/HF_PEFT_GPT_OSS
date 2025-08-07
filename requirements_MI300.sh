#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
# Change this if you want a different python executable
PYTHON=python3

# Ensure pip is up to date
"$PYTHON" -m pip install --upgrade pip

# Uninstall any existing versions
python3 -m pip uninstall -y transformers accelerate

# Install the exact versions you want
python3 -m pip install transformers==4.55.0 accelerate==1.9.0


echo "All Packages Installed for MI300!"
