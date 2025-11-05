#!/bin/bash
#
# Complete PPRL Demonstration Runner
# This script runs the entire demonstration from start to finish

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================================"
echo "Complete PPRL Demonstration"
echo "Super Hero Hospital & Pharmacy Record Linkage"
echo "============================================================"
echo ""

# Step 1: Generate datasets
echo -e "${BLUE}Step 1: Generating Datasets${NC}"
echo "Creating hospital and pharmacy datasets with 40% overlap..."
python3 "$SCRIPT_DIR/generate_superhero_datasets.py"
echo ""

# Step 2: Tokenize datasets
echo -e "${BLUE}Step 2: Tokenizing Datasets${NC}"
echo "Each organization tokenizes their data independently..."
"$SCRIPT_DIR/tokenize_datasets.sh"
echo ""

# Step 3: Analyze overlap
echo -e "${BLUE}Step 3: Analyzing Overlap${NC}"
echo "Decrypting tokens and finding matches..."
python3 "$SCRIPT_DIR/analyze_overlap.py"
echo ""

echo "============================================================"
echo -e "${GREEN}Demonstration Complete!${NC}"
echo "============================================================"
echo ""
echo "Summary of Generated Files:"
echo "  Datasets:"
echo "    - ../datasets/hospital_superhero_data.csv"
echo "    - ../datasets/pharmacy_superhero_data.csv"
echo ""
echo "  Tokenized Data:"
echo "    - ../outputs/hospital_tokens.csv"
echo "    - ../outputs/pharmacy_tokens.csv"
echo ""
echo "  Analysis Results:"
echo "    - ../outputs/matching_records.csv"
echo ""
echo "Expected Result: 40 matching patients identified"
