#!/bin/bash

#Genevieve Mortensen
#mod. 09/25/2022
#Change directory to where all the .sam files are.
cd /home/gamorten/prj/pergnant/no_host_km

#concatenate filenames found to a text file, referenced by variable S
S=$(cat /home/kmorten/prego/metadata/samples.txt)

#Output directory
OUT_SAMTOOL="/home/gamorten/prj/pergnant/no_host"

#mkdir only if it doesn't exist already so we don't make duplicate directories
mkdir -p $OUT_SAMTOOL

#if commands file exists, delete it so as not to append to the currently existing command file
if [ -f samtool_split_commands_A.txt ]; then
	        rm samtool_split_commands_A.txt
fi

if [ -f samtool_split_commands_B.txt ]; then
	                rm samtool_split_commands_B.txt
fi

#symlink files
#iterate through each filename in our variable containing the file of our filenames
for SRR in ${S[@]}; do
	
        #input is our bam file
	F1_IN="${SRR}_bothReadsUnmapped.bam"
	#output is our unmapped reads
	S_OUT="${SRR}_bothReadsUnmapped_sorted.bam"
	F1_OUT="${SRR}_host_removed_R1.fastq.gz"
	F2_OUT="${SRR}_host_removed_R2.fastq.gz"

        #samtool filter command to get unmapped pairs
	        echo "/home/kmorten/bin/samtools-1.14/samtools sort -n -m 5G -@ 2 ${F1_IN} -o ${S_OUT}" >> samtool_split_commands_A.txt
		echo "/home/kmorten/bin/samtools-1.14/samtools fastq -@ 8 ${S_OUT} -1 ${F1_OUT} -2 ${F2_OUT} -0 /dev/null -s /dev/null -n" >> samtool_split_commands_B.txt
	done
	
#parallel -j 8 < /home/gamorten/prj/pergnant/no_host_km/samtool_split_commands_A.txt
#ln -s /home/gamorten/prj/pergnant/no_host_km/* /home/gamorten/prj/pergnant/no_host/
