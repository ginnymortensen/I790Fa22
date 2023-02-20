#!/bin/bash

# Genevieve Mortensen 
# mod 09/19/2022
# Creates a command script for samtools (create fastq files for input into multiQC)

#Change directory to where all the .sam files are.
cd /home/gamorten/prj/pergnant/no_host_km

#concatenate filenames found to a text file, referenced by variable S
S=$(cat /home/kmorten/prego/metadata/samples.txt)

#Output directory
OUT_SAMTOOL="/home/gamorten/prj/pergnant/no_host"

#mkdir only if it doesn't exist already so we don't make duplicate directories
mkdir -p $OUT_SAMTOOL

#if commands file exists, delete it so as not to append to the currently existing command file
if [ -f samtool_conversion_commands.txt ]; then
	rm samtool_conversion_commands.txt
fi

#symlink files
#ln -s /home/gamorten/prj/pergnant/no_host_km/* /home/gamorten/prj/pergnant/no_host/.

#iterate through each filename in our variable containing the fileof our filenames
for SRR in ${S[@]}; do

	#input is our sam file
	F1_IN="${SRR}_mapped_and_unmapped.sam"
	#output is our bam file
	S_OUT="${SRR}_mapped_and_unmapped.bam"
	
	#samtool command
	echo "/home/kmorten/bin/samtools-1.14/samtools view -bS ${F1_IN} > ${S_OUT}" >> samtool_conversion_commands.txt
done

#parallel -j 8 < /home/gamorten/prj/pergnant/no_host/samtool_conversion_commands.txt
