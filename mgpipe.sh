#!/bin/bash

# Genevieve Mortensen
# Wrapper script to run various metagenomic processing scripts.
# Allows the user to skip specific parts of the pipeline.

# Default behavior: don't skip anything
SKIP_TRIMMER=false
SKIP_HOST_REMOVER=false
SKIP_TAXONOMIC_PROFILER=false
SKIP_FUNCTIONAL_PROFILER=false

# Function to parse the --skip argument
parse_skip() {
    IFS=',' read -ra SKIP <<< "$1"  # Split the argument into an array based on commas
    for skip_stage in "${SKIP[@]}"; do
        case "$skip_stage" in
            trimmer)
                SKIP_TRIMMER=true
                ;;
            host_remover)
                SKIP_HOST_REMOVER=true
                ;;
            taxonomic_profiler)
                SKIP_TAXONOMIC_PROFILER=true
                ;;
            functional_profiler)
                SKIP_FUNCTIONAL_PROFILER=true
                ;;
            *)
                echo "Invalid skip option: $skip_stage. Use one or more of: trimmer, host_remover, taxonomic_profiler, functional_profiler"
                exit 1
                ;;
        esac
    done
}

# Function to run trimmer.sh and handle the raw directory
run_trimmer() {
    if [[ "$SKIP_TRIMMER" = true ]]; then
        echo "Skipping trimming stage..."
        return
    fi

    # Check if the 'raw' directory exists
    if [[ -d "raw" ]]; then
        echo "Found 'raw' directory. Using it for input."
        RAW_DIR="raw"
    else
        # If 'raw' directory is not found, prompt the user to provide one
        echo "'raw' directory not found. Please provide the path to the raw sequence directory:"
        read -rp "Enter the raw sequence directory: " RAW_DIR

        # Check if the provided directory exists
        if [[ ! -d "$RAW_DIR" ]]; then
            echo "Error: Provided directory '$RAW_DIR' does not exist."
            exit 1
        fi
    fi

    # Run the trimmer.sh script with the detected or provided raw directory
    bash "./trimmer.sh" "$RAW_DIR"
}

# Function to run host_remover.sh
run_host_remover() {
    if [[ "$SKIP_HOST_REMOVER" = true ]]; then
        echo "Skipping host removal stage..."
        return
    fi
    bash "./host_remover.sh" "$@"
}

# Function to run taxonomic_profiler.sh
run_taxonomic_profiler() {
    if [[ "$SKIP_TAXONOMIC_PROFILER" = true ]]; then
        echo "Skipping taxonomic profiling stage..."
        return
    fi
    bash "./taxonomic_profiler.sh" "$@"
}

# Function to run functional_profiler.sh
run_functional_profiler() {
    if [[ "$SKIP_FUNCTIONAL_PROFILER" = true ]]; then
        echo "Skipping functional profiling stage..."
        return
    fi
    bash "./functional_profiler.sh" "$@"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip)
            if [[ -z "$2" ]]; then
                echo "Error: --skip requires a comma-separated list of stages (e.g., trimmer,host_remover)"
                exit 1
            fi
            parse_skip "$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--skip stage1,stage2,...] {optional arguments}"
            exit 1
            ;;
    esac
done

# Execute pipeline steps in order
run_trimmer
run_host_remover
run_taxonomic_profiler
run_functional_profiler

echo "Pipeline completed."
