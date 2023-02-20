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
if [ -f samtool_filter_commands.txt ]; then
	        rm samtool_filter_commands.txt
fi

#symlink files
#iterate through each filename in our variable containing the file of our filenames
for SRR in ${S[@]}; do
	
        #input is our bam file
	F1_IN="${SRR}_mapped_and_unmapped.bam"
	#output is our unmapped reads
	S_OUT="${SRR}_bothReadsUnmapped.bam"
			
        #samtool filter command to get unmapped pairs
	        echo "/home/kmorten/bin/samtools-1.14/samtools view -b -f 12 -F 256 ${F1_IN} > ${S_OUT}" >> samtool_filter_commands.txt
	done
	
#parallel -j 8 < /home/gamorten/prj/pergnant/no_host/samtool_filter_commands.txt
#ln -s /home/gamorten/prj/pergnant/no_host_km/* /home/gamorten/prj/pergnant/no_host/
