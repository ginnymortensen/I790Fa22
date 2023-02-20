#!/bin/bash
#Created by Genevieve Mortensen 11/10/2022
#Adapted from pipepline.sh by Etienne Nzabarushimana for humann3 table joining

#Folder containing SRR names
S="pregnancy_combined"

#Folder containing pathabundance.tsv's
WDIR="/home/gamorten/prj/pergnant/humann_work"
cd $WDIR

#Find the number of sample outputs and echo to command line
n=$(ls -l ${WDIR}/*pathabundance.tsv* | wc -l )
echo $n

#Delete existing files
if [ -f ${S}_pathabundance.tsv ] || [ -f ${S}-cpm.tsv ]; then
	rm ${S}_pathabundance.tsv ${S}-cpm.tsv
fi

#Join all path abundance files into a large table
humann_join_tables -i ${WDIR} -o ${S}_pathabundance.tsv --file_name pathabundance.tsv

#renormalize the table
humann_renorm_table -i ${S}_pathabundance.tsv -o ${S}-cpm.tsv --units cpm --update-snames

#Filter out unintegrated and unmapped reads
grep -v UNINT ${S}-cpm.tsv | grep -v UNMA | grep -v "|"  > ${S}.integrated-pwz-red

### Get the outputs with shortened pathways names
awk -v nt="$n" '{printf $1 "\t"}{i = nt; for (--i; i >= 0; i--){ printf "%s\t",$(NF-i)} print ""}' ${S}.integrated-pwz-red | sed 's/://g' | sed 's/#/Pathway/g' | awk '$1=$1' > ${S}.pwz-cpm.tsv

### changes sample names 
sed -i 's/_Abundance-CPM//g' ${S}.pwz-cpm.tsv


