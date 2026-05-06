#!/bin/bash
#SBATCH --job-name=prepare-venv
#SBATCH --cpus-per-task=8
#SBATCH --mem=480G
#SBATCH --partition=gpupilot
#SBATCH --time=1:00:00
#SBATCH --gpus-per-node=1
#SBATCH --account=project_2017850
#SBATCH --output logs/%j.out
#SBATCH --error logs/%j.err

# Install TransformerEngine, apex and Megatron Core into a venv using
# a relevant module configuration.

# Directory to create for venv
VENV_DIR="/scratch/$SLURM_JOB_ACCOUNT/venv/python-pytorch-megatron"

# TransformerEngine repository and branch to use
export TE_REPO="https://github.com/NVIDIA/TransformerEngine.git"
export TE_BRANCH="stable"

# apex repository and commit to use (was most recent when tested)
export APEX_REPO="https://github.com/NVIDIA/apex.git"
export APEX_COMMIT="0857d7b"

# Check that we're running as a slurm job
if [ -z "$SLURM_JOB_ID" ]; then
    echo "Run this script as a slurm job with \`sbatch $0\`"
    exit 1
fi

# Bash "strict mode"
# (see http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail

# Avoid LD_PRELOAD error messages
unset LD_PRELOAD

# Set up modules
module purge  # avoid compiler and cuda conflicts
module load python-pytorch 

# Venv directory
if [ -e "$VENV_DIR" ]; then
    echo "$VENV_DIR exists, not clobbering (exit)"
    exit 1
fi

echo "Creating venv in $VENV_DIR"

# Create and activate venv
mkdir -p "$(dirname "$VENV_DIR")"
cd "$(dirname "$VENV_DIR")"
python -m venv "$(basename "$VENV_DIR")" --system-site-packages  
source "$(basename "$VENV_DIR")/bin/activate"

# Create temporary directory for compile, delete on exit
export TMPDIR="$(mktemp -d "/tmp/$USER/tmp.XXXXXX")"

cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT		

# Use for compilation
export CMAKE_TEMP_DIR="$TMPDIR"
export BUILD_DIR="$TMPDIR"

# Compilation envs
export NVTE_BUILD_THREADS=4
export MAX_JOBS=4
export NVTE_FRAMEWORK=pytorch
export NVTE_CUDA_ARCHS="90"

# Clone TE into $TMPDIR
cd $TMPDIR
git clone --branch "$TE_BRANCH" --recursive "$TE_REPO"
cd TransformerEngine

# Install TransformerEngine from source
echo "START pip install for TransformerEngine: $(date)"
pip install -v --no-build-isolation .
echo "DONE pip install for TransformerEngine: $(date)"

# Clone apex into $TMPDIR
cd $TMPDIR
git clone "$APEX_REPO"
cd apex
git checkout "$APEX_COMMIT"

# Install apex from source
echo "START pip install for apex: $(date)"
APEX_CPP_EXT=1 APEX_CUDA_EXT=1 pip install -v --no-build-isolation .
echo "DONE pip install for apex: $(date)"

# Install Megatron Core
pip install megatron-core

cat <<EOF

Installed TransformerEngine, apex, and Megatron Core into venv in
$VENV_DIR.

Usage:

    module purge
    module load python-pytorch 
    source $VENV_DIR/bin/activate

EOF
