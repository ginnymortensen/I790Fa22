#!/bin/bash
#Created by Genevieve Mortensen 10/29/2022
#Adapted from hmn by Etienne Nzabarushimana for humann3 usage

#Directory of our input data
DIR=/home/gamorten/prj/pergnant/no_host
#go to this directory to run the commanparallel -j 4 </home/gamorten/prj/pergnant/

#File containing the names of our samples, all cat to $S
S=$(cat /home/kmorten/prego/metadata/samples.txt)

#Output directory
OUT_THIS="/home/gamorten/prj/pergnant/humann_work"
#make it if it doesnt exist already but I know it does so whatever. Someone else can adapt from this. I don't care.
mkdir -p $OUT_THIS

#Create a .txt file containing our commands
if [ -f humann_commands_GM.txt ]; then
	rm humann_commands_GM.txt
fi

#Iterate through each filename stored in $S and perform an action
for SRR in ${S[@]}; do

	#Concatenate both reads for each sample
	#echo "cat ${SRR}_host_removed_R1.fastq.gz >> ${SRR}_no_host.fastq.gz" >> cat_1_fqgz.txt
	#echo "cat ${SRR}_host_removed_R2.fastq.gz >> ${SRR}_no_host.fastq.gz" >> cat_2_fqgz.txt

	#Write command to a text file
	echo "humann -i ${SRR}_no_host.fastq.gz -o ${OUT_THIS} --threads 24 &>log-${SRR}" >> humann_commands_GM.txt
	done


#parallel -j 4 </home/gamorten/prj/pergnant/
#mv ${line}_humann_temp/${line}.log .
#rm -rf ${line}_humann_temp
