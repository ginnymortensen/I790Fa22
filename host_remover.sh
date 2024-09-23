#!/bin/bash

# Genevieve Mortensen
# 09/11/2024
# Use this script to remove host genome sequences from trimmed and filtered reads using bowtie2.

# Directories and files
PROCESSED_DIR="processed"
OUTPUT_DIR="non_host"
DB_PATH="databases/bowtie_indexes/"
INDEX_PATH="databases/bowtie_indexes/grch38_1kgmaj"
FASTA_PATH="databases/bowtie_indexes/grch38_1kgmaj.fa"
FASTA_URL="ftp://ftp.ccb.jhu.edu/pub/data/bowtie_indexes/grch38_1kgmaj.fa.gz"
REPORT_DIR="reports"
NUM_THREADS=8  # Number of threads to use for Bowtie2 and Samtools
PARALLEL_JOBS=4  # Number of parallel jobs to run simultaneously

# Create output directories if they don't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$REPORT_DIR"

# Check if Bowtie2 index exists
if [[ ! -f "${INDEX_PATH}.1.bt2" ]]; then
    echo "Bowtie2 index not found."

    # Check if the FASTA file exists
    if [[ ! -f "$FASTA_PATH" ]]; then
        echo "FASTA file not found. Downloading from $FASTA_URL..."
        mkdir -p "$DB_PATH"
        wget -O "$FASTA_PATH.gz" "$FASTA_URL"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to download FASTA file. Exiting."
        fi
        gunzip "$FASTA_PATH.gz"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to unzip FASTA file. Exiting."
        fi
        echo "FASTA file downloaded and unzipped successfully."
    else
        echo "FASTA file found. Proceeding to build the Bowtie2 index."
    fi

    # Build the Bowtie2 index
    echo "Building Bowtie2 index from ${FASTA_PATH}..."
    bowtie2-build "$FASTA_PATH" "$INDEX_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to build Bowtie2 index. Exiting."
    fi
    echo "Bowtie2 index successfully built."
else
    echo "Bowtie2 index found. Proceeding with alignment."
fi

# Function to process each sample
process_sample() {
    R1_FILE="$1"
    BASENAME=$(basename "$R1_FILE" | sed 's/_R1_trimmed.fastq.gz//')
    R2_FILE="$PROCESSED_DIR/${BASENAME}_R2_trimmed.fastq.gz"

    if [[ -f "$R1_FILE" && -f "$R2_FILE" ]]; then
        echo "Processing sample $BASENAME..."

        # Align to human genome using Bowtie2
        bowtie2 -x "$INDEX_PATH" -1 "$R1_FILE" -2 "$R2_FILE" \
            --very-sensitive -S "$OUTPUT_DIR/${BASENAME}_human_mapped.sam" \
            --threads "$NUM_THREADS" \
            2> "$REPORT_DIR/${BASENAME}_bowtie2.log"

        # Check if Bowtie2 successfully created the SAM file
        if [[ -f "$OUTPUT_DIR/${BASENAME}_human_mapped.sam" ]]; then
            # Convert SAM to BAM with both mapped and unmapped reads
            samtools view -bS "$OUTPUT_DIR/${BASENAME}_human_mapped.sam" \
                -o "$OUTPUT_DIR/${BASENAME}_human_mapped.bam" -@ "$NUM_THREADS"

            # Extract non-host (unmapped) reads
            samtools view -b -f 12 -F 256 "$OUTPUT_DIR/${BASENAME}_human_mapped.bam" \
                -o "$OUTPUT_DIR/${BASENAME}_non_human.bam" -@ "$NUM_THREADS"

            # Convert non-host BAM back to FASTQ
            bedtools bamtofastq -i "$OUTPUT_DIR/${BASENAME}_non_human.bam" \
                -fq "$OUTPUT_DIR/${BASENAME}_R1_non_host.fastq" \
                -fq2 "$OUTPUT_DIR/${BASENAME}_R2_non_host.fastq"

            # Clean up intermediate files (optional)
            rm -f "$OUTPUT_DIR/${BASENAME}_human_mapped.sam"
            rm -f "$OUTPUT_DIR/${BASENAME}_human_mapped.bam"

            echo "Finished processing sample $BASENAME."
        else
            echo "Error: SAM file not created for sample $BASENAME. Check Bowtie2 logs."
        fi
    else
        echo "Warning: Paired-end files for $BASENAME not found or incomplete."
    fi
}

# Export functions and variables for xargs parallel execution
export -f process_sample
export PROCESSED_DIR OUTPUT_DIR INDEX_PATH REPORT_DIR NUM_THREADS

# Run sample processing in parallel using xargs
find "$PROCESSED_DIR" -name '*_R1_trimmed.fastq.gz' | xargs -n 1 -P "$PARALLEL_JOBS" -I {} bash -c 'process_sample "$@"' _ {}

echo "All files processed."
