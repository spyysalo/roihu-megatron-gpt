#!/bin/bash

# Script to download and verify preprocessed binary data for LLM
# pretraining

set -euo pipefail

PROJECT="project_2017850"    # set to match your account

module load python-pytorch    # for roihu

DATA_DIR="/scratch/$PROJECT/preprocessed/wikipesto"

# Permissively licensed data from Common Pile (Wiki + peS2o)
BASE_URL="https://462000963.lumidata.eu/common-pile/wikipesto"

VERIFY_SCRIPT_URL="https://raw.githubusercontent.com/spyysalo/datamix-tools/refs/heads/main/megatrondata.py"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# Download binary and index, with info for verification
wget --no-clobber "$BASE_URL".{bin,idx,info.json}

# Download script for verification
wget --no-clobber "$VERIFY_SCRIPT_URL"

python3 megatrondata.py verify "$(basename "$BASE_URL")".{bin,info.json}
