#!/bin/bash
# Setup Python virtual environment and install packages

set -e

echo "Setting up Python virtual environment..."

# Create virtual environment in the workspace
python3 -m venv /workspaces/OpenToken/.venv

# Activate virtual environment
source /workspaces/OpenToken/.venv/bin/activate

# Upgrade pip
python -m pip install --upgrade pip

# Install ipykernel for Jupyter support
pip install ipykernel

# Install opentoken core package
echo "Installing opentoken core package..."
cd /workspaces/OpenToken/lib/python
pip install -e .

# Install opentoken-pyspark package
echo "Installing opentoken-pyspark package..."
cd /workspaces/OpenToken/lib/python/opentoken-pyspark
pip install -r requirements.txt
pip install -e .

# Register the kernel with Jupyter
python -m ipykernel install --user --name=opentoken --display-name="Python (OpenToken)"

echo "Python environment setup complete!"
echo "Virtual environment location: /workspaces/OpenToken/.venv"
echo "To activate: source /workspaces/OpenToken/.venv/bin/activate"
