#!/bin/bash   ###shebang shows you which language you're using and where to find it.

# Author: Genevieve Mortensen
# Last Modified: 02-06-2023
#		 03-29-2023

# Description: This script creates a command script for Trimmomatic and FastQC runs (pre/post trimming). 

#################################################################################

# location of raw sequences
RAW="/N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data"  ###RAW is the variable holding our PATH to our seqeuences. 
				    ### There must be no spaces by the equal sign. and the path must start with a forward slash.

# SRR accession fastq file names.
#S=($(find ${RAW} -wholename "*.fastq.gz" -printf '%f\n'|sed "\_R[12]\_001.fastq.gz"|sort|uniq))
S=$(cat /N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data/samples.txt)  


# output directories
OUT_TRIM="/N/project/MicrobiomeHealth/pregnant/data/Lin-data_output/trim"

# makes output directory if and only if it doesn't exist
mkdir -p $OUT_TRIM  

# if commands.txt file exists, delete
if [ -f trim_commands.txt ]; then   ###This is the specific syntax to write an if statement just beware of spacing 
	rm trim_commands.txt         ### -f flag means file
fi					### This step is necessary because we want to delete any previous trim_commands.txt
					 ### file we created instead of appending to it.

# initiate by loading necessary modules 
#echo "module load fastqc" >> trim_commands.txt

# loops through SRRs & append commands.txt with trim, singleton, & fastqc scripts
for SRR in ${S[@]}; do   ### Be mindful of semicolons; do you wanna build a snowman.
#this is just a regular for loop, the syntax is how it is if you wanna go through a list.
	# variables
       	R1_in="${RAW}/${SRR}_R1_001.fastq.gz"
        R2_in="${RAW}/${SRR}_R2_001.fastq.gz" 

        R1_paired="${OUT_TRIM}/${SRR}_1_pairedTrim.fastq.gz"
        R1_unpaired="${OUT_TRIM}/${SRR}_1_unpairedTrim.fastq.gz"
        R2_paired="${OUT_TRIM}/${SRR}_2_pairedTrim.fastq.gz"
        R2_unpaired="${OUT_TRIM}/${SRR}_2_unpairedTrim.fastq.gz"

	# Trimmomatic script	
	echo "java -jar $TRIM \
	PE -phred33 \
	${R1_in} ${R2_in} \
	${R1_paired} ${R1_unpaired} \
	${R2_paired} ${R2_unpaired} \
	ILLUMINACLIP:TrueSeq3-PE.fa:2:30:10 \
	TRAILING:20 LEADING:20 SLIDINGWINDOW:4:20 MINLEN:36" \
	>> trim_commands.txt 

done

# parallel -j 20 < /home/gamorten/prj/pergnant/trim_commands.txt


### for loops in bash require a "done"

