#!/bin/bash   ###shebang shows you which language you're using and where to find it.

# Author: Genevieve Mortensen
# Last Modified: 02-06-2023

# Description: This script concatenates files in nested directories which are created by ENA's downloader tool. 

################################################################################

#specify paths downstream of the MicrobiomeHealth folder. This is for user convenience.

# location of the temp file containing the sample file names (without the extension) 
S="/N/project/MicrobiomeHealth/$1"

# Upstream directory containing each directory corresponding to each sample
RAW="/N/project/MicrobiomeHealth/$2"

# output directory should be outside of the PRJ* directory where the nested directories are.
OUTDIR="/N/project/MicrobiomeHealth/$3"

# loops through SRRs and concatenates them for 
for SRR in ${S[@]}; do

       	cat "${RAW}/${SRR}_R1_001.fastq.gz" >> "${OUTDIR}/${SRR}.fastq.gz"
        cat "${RAW}/${SRR}_R2_001.fastq.gz" >> "${OUTDIR}/${SRR}.fastq.gz"
	
done
