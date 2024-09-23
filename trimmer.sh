#!/bin/bash

# Genevieve Mortensen
# 09/11/2024
# Use this script on raw Illumina paired-end reads to trim and filter fastq.gz sequence files using fastp.

# Directory containing raw sequences
RAW_DIR="raw"
OUTPUT_DIR="processed"
REPORT_DIR="reports"

# Create output and report directories if they don't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$REPORT_DIR"

# Loop over all R1 files in the directory
for R1_FILE in "$RAW_DIR"/*_R1_001.fastq.gz
do
    # Extract base filename for R1 and R2 by removing the *_R1_001 part
    BASENAME=$(basename "$R1_FILE" | sed 's/_R1_001.*//')
    R2_FILE="$RAW_DIR/${BASENAME}_R2_001.fastq.gz"

    # Check if both R1 and R2 files exist
    if [[ -f "$R1_FILE" && -f "$R2_FILE" ]]; then
        # Define output files for trimmed data and reports
        OUT_R1="$OUTPUT_DIR/${BASENAME}_R1_trimmed.fastq.gz"
        OUT_R2="$OUTPUT_DIR/${BASENAME}_R2_trimmed.fastq.gz"
        HTML_REPORT="$REPORT_DIR/${BASENAME}_fastp_report.html"
        JSON_REPORT="$REPORT_DIR/${BASENAME}_fastp_report.json"

        # Run fastp on the paired-end files
        echo "Processing $BASENAME..."
        fastp -i "$R1_FILE" -I "$R2_FILE" \
              -o "$OUT_R1" -O "$OUT_R2" \
              --html "$HTML_REPORT" --json "$JSON_REPORT" \
              --thread 4

        echo "Finished processing $BASENAME"

    else
        echo "Warning: Paired-end files for $BASENAME not found or incomplete."
    fi
done

echo "All files processed."