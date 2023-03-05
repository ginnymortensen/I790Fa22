#!/bin/bash

#KRAKENDB=/N/project/MicrobiomeHealth/pregnant/database
#THISLIB=/N/project/MicrobiomeHealth/pregnant/lib
MINLEN=60
THREADS=12

while read -r QUERY <&3; do
    echo "$QUERY"
    INDIR=${DATA}
    OUTDIR=${OUT}
    ERR="${QUERY}.sra"

    #create folder if it doesn't exist
    if test -f "$OUTDIR"; then
        echo "$OUTDIR exists"
    else
    	mkdir -p ${OUTDIR}
    fi

    #download if file doesn't exist
    FILEPE="${INDIR}/${QUERY}/${QUERY}.fastq.gz"
    if test -f "$FILEPE"; then
       FILE=$FILEPE
       echo "$FILE exists."
    else 
	FILE="nosuchfile"
        echo "no fastq file found"
    fi 
    # run kraken & braken
    if test -f "$FILE"; then
       echo "Running Kraken2: ${ERR}"
       kraken2 --db ${KRAKENDB} --thread ${THREADS} --report ${OUTDIR}/${QUERY}.kreport --out ${OUTDIR}/${QUERY}.kraken ${FILE}
       echo "Kraken2 Complete"

       # filter kraken results to bacteria only
       echo "filtering Kraken: ${ERR}"
       python3 ${THISLIB}/kraken_filter.py -k ${OUTDIR}/${QUERY}.kreport -o ${OUTDIR}/${QUERY}.filtered.kreport 

       # run bracken on filtered kraken results
       # bracken -d ${DB} -i ${kreport} -o {OUTPUT} -w ${braken_report} -r {READLEN} -l {S}
       echo "Running Bracken: ${ERR}"
       bracken -d ${KRAKENDB} -i ${OUTDIR}/${QUERY}.filtered.kreport -o ${OUTDIR}/${QUERY}.bac_only.s.bracken -w ${OUTDIR}/${QUERY}.bac_only.s.breport -l S
       bracken -d ${KRAKENDB} -i ${OUTDIR}/${QUERY}.filtered.kreport -o ${OUTDIR}/${QUERY}.bac_only.s1.bracken -w ${OUTDIR}/${QUERY}.bac_only.s1.breport -l S1
       echo "Bracken Complete"
   fi
done 3<$INFILE
