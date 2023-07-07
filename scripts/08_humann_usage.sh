#!/bin/bash
#Created by Genevieve Mortensen 10/29/2022
#Adapted from hmn by Etienne Nzabarushimana for humann3 usage

#Directory of our input data
DIR=/N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data
cd ${DIR}

#Output directory
OUT_THIS="/N/project/MicrobiomeHealth/pregnant/data/humann_work/Lin_output"
#make it if it doesnt exist already.
mkdir -p ${OUT_THIS}

#Write command to a text file
humann -i $1 -o $OUT_THIS --threads 24
