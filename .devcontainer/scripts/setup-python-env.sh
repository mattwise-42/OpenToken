#!/bin/bash
# Setup Python virtual environment and install packages

set -e

echo "Setting up Python virtual environment..."

# Get the workspace folder (use PWD if not set)
WORKSPACE_DIR="${containerWorkspaceFolder:-$(pwd)}"

# Create virtual environment in the workspace
python3 -m venv "${WORKSPACE_DIR}/.venv"

# Activate virtual environment
source "${WORKSPACE_DIR}/.venv/bin/activate"

# Upgrade pip
python -m pip install --upgrade pip

# Install ipykernel for Jupyter support
pip install ipykernel

# Install opentoken core package
echo "Installing opentoken core package..."
cd "${WORKSPACE_DIR}/lib/python"
pip install -e .

# Install opentoken-pyspark package
echo "Installing opentoken-pyspark package..."
cd "${WORKSPACE_DIR}/lib/python/opentoken-pyspark"
pip install -r requirements.txt
pip install -e .

# Register the kernel with Jupyter
python -m ipykernel install --user --name=opentoken --display-name="Python (OpenToken)"

echo "Python environment setup complete!"
echo "Virtual environment location: ${WORKSPACE_DIR}/.venv"
echo "To activate: source ${WORKSPACE_DIR}/.venv/bin/activate"
