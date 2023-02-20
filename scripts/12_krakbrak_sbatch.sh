#!/bin/bash

#SBATCH -J pregnant
#SBATCH -p general
#SBATCH -o /N/u/gamorten/Carbonate/pregnant/output.log
#SBATCH -e /N/u/gamorten/Carbonate/pregnant/error.log 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gamorten@iu.edu
#SBATCH --nodes=1
#SBATCH --mem=128gb
#SBATCH --ntasks-per-node=1
#SBATCH --time=03:00:00

export INFILE=/N/project/MicrobiomeHealth/pregnant/metadata/samples-2.txt 
export DATA=/N/project/MicrobiomeHealth/pregnant/data/no_host
export OUT=/N/project/MicrobiomeHealth/pregnant/data/braken_work
export KRAKENDB=/N/project/MicrobiomeHealth/pregnant/database
export THISLIB=/N/project/MicrobiomeHealth/pregnant/lib

#srun bash ./quantify_bracken.sh
bash /N/project/MicrobiomeHealth/pregnant/scripts/11_quantify_braken.sh
