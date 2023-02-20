#!/bin/bash
#Created by Genevieve Mortensen 02/16/2023

#Name of new file
S="preg_gf_combined"

#Folder containing genefamily.tsv's
WDIR="/N/project/MicrobiomeHealth/pregnant/data/humann_work"
cd $WDIR

#Find the number of sample outputs and echo to command line
n=$(ls -l ${WDIR}/*genefamilies.tsv* | wc -l )
echo $n

#Delete existing files
#if [ -f ${S}_genefamilies.tsv ] || [ -f ${S}-cpm.tsv ]; then
#	rm ${S}_genefamilies.tsv ${S}-cpm.tsv
#fi

#Join all gene family files into a large table
humann_join_tables -i ${WDIR} -o ${S}_genefamilies.tsv --file_name genefamilies.tsv

#renormalize the table
humann_renorm_table -i ${S}_genefamilies.tsv -o ${S}_genefamilies-cpm.tsv --units cpm --update-snames

#Filter out unintegrated and unmapped reads
grep -v UNINT ${S}-cpm.tsv | grep -v UNMA | grep -v "|"  > ${S}.integrated-genefams-red

#Regroup functional categories
humann_regroup_table -i ${S}_genefamilies-cpm.tsv -o ${S}_rxn-cpm.tsv --groups uniref50_rxn

#Assign functional names
humann_rename_table --input ${S}_rxn-cpm.tsv --output ${S}_rxn-cpm-named.tsv --names metacyc-rxn

#Filter out species-specific gene family names
awk -v nt="$n" '{printf $1 "\t"}{i = nt; for (--i; i >= 0; i--){ printf "%s\t",$(NF-i)} print ""}' ${S}.integrated-genefams-red | sed 's/://g' | sed 's/#/Gene Family/g' | awk '$1=$1' > ${S}.gf-cpm.tsv

#Changes sample names 
sed -i 's/_GeneFamilies//g' ${S}.gf-cpm.tsv
