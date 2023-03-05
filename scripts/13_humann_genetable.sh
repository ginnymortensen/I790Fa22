#!/bin/bash
#Created by Genevieve Mortensen 02/16/2023

#Name of new file
S="preg_gf_combined"

#concatenate names in sample text file
I=$(cat /N/project/MicrobiomeHealth/pregnant/metadata/gfsamps.txt)

#Folder containing genefamily.tsv's
WDIR="/N/project/MicrobiomeHealth/pregnant/data/humann_work"
cd $WDIR

#Output directory
OUTDIR="/N/project/MicrobiomeHealth/pregnant/data/humann_work/genefams"
mkdir -p $OUTDIR

#Find the number of sample outputs and echo to command line
n=$(ls -l ${WDIR}/*genefamilies.tsv* | wc -l )
echo $n

#Delete existing files
if [ -f ${S}_genefamilies.tsv ] || [ -f ${S}-cpm.tsv ]; then
	rm ${S}_genefamilies.tsv ${S}-cpm.tsv
fi

#renormalize the table
for SRR in ${I[@]}; do
	humann_renorm_table -i ${SRR} -o ${OUTDIR}/${SRR}-cpm.tsv --units cpm --update-snames
done

#change directories
cd $OUTDIR

#Join all gene family files into a large table
humann_join_tables -i ${OUTDIR} -o ${S}_genefamilies.tsv --file_name genefamilies.tsv

#Filter out unintegrated and unmapped reads
grep -v UNINT ${S}_genefamilies.tsv | grep -v UNMA | grep -v "|"  > ${S}.integrated-genefams-red

#Regroup functional categories
humann_regroup_table -i ${S}.integrated-genefams-red -o ${S}_rxn-cpm.tsv --groups uniref50_rxn

#Assign functional names
humann_rename_table --input ${S}_rxn-cpm.tsv --output ${S}_rxn-cpm-named.tsv --names metacyc-rxn

#Filter out species-specific gene family names
awk -v nt="$n" '{printf $1 "\t"}{i = nt; for (--i; i >= 0; i--){ printf "%s\t",$(NF-i)} print ""}' ${S}_rxn-cpm-named.tsv | sed 's/://g' | sed 's/#/Gene Family/g' | awk '$1=$1' > ${S}_final.tsv

#Changes sample names 
sed -i 's/_GeneFamilies//g' ${S}_final.tsv
