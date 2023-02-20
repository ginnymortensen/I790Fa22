#!/bin/bash

# Genevieve Mortensen 
# mod 09/19/2022
# Creates a command script for Bowtie2 (host removal)

#cp /home/gamorten/prj/pergnant/trim/S00JD-0048_S61_L001* /home/gamorten/prj/pergnant/GRCh38_noalt_as/. Created symlink called trim to reference sequences. bowtie2 operates in the directory GRCh38_noalt_as. Files have to be in this directory.
cd /home/gamorten/prj/pergnant/GRCh38_noalt_as

#Reuse the file names generated when 03_trim.sh was run.
#S=($(find ${RAW} -wholename "*.fastq.gz" -printf '%f\n'|sed "\_R[12]\_001.fastq.gz"|sort|uniq))


#concatenate filenames found to a text file, ref by variable
S=$(cat /home/kmorten/prego/metadata/samples.txt)

#Output directory
OUT_BOWTIE="/home/gamorten/prj/pergnant/no_host"

#mkdir only if it doesn't exist
mkdir -p $OUT_BOWTIE

#if commands file exists, delete it so as not to append.
if [ -f bowtie_commands_KM.txt ]; then
	rm bowtie_commands_KM.txt
fi

#symlink this shizzz
ln -s /home/gamorten/prj/pergnant/trim/* /home/gamorten/prj/pergnant/GRCh38_noalt_as/.


#iterate through each filename in our variable of filenames
for SRR in ${S[@]}; do

	#input
	F1_IN="${SRR}_1_pairedTrim.fastq.gz"  
	F2_IN="${SRR}_2_pairedTrim.fastq.gz"  
	S_OUT="${SRR}_mapped_and_unmapped.sam"
	
	#bowtie2 command **For some reason the alias for bowtie isnt working??**
	echo "/home/kmorten/bin/bowtie2-2.4.2-sra-linux-x86_64/bowtie2 \
	-p 8 \
	-x GRCh38_noalt_as \
	-1 ${F1_IN} \
	-2 ${F2_IN} \
	-S ${S_OUT}" \
	>> bowtie_commands_KM.txt
done

#parallel -j 8 < /home/gamorten/prj/pergnant/GRCh38_noalt_as/bowtie_commands_KM.txt
