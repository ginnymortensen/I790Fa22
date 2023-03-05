#!/bin/bash

#SBATCH -J Lindata
#SBATCH -p general
#SBATCH -o /N/u/gamorten/Carbonate/pregnant/output.log
#SBATCH -e /N/u/gamorten/Carbonate/pregnant/error.log 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gamorten@iu.edu
#SBATCH --nodes=1
#SBATCH --mem=500gb
#SBATCH --ntasks-per-node=1
#SBATCH --time=30:00:00

export INFILE=/N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data/PRJEB13870/PRJEB13870_temp.txt 
export DATA=/N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data/PRJEB13870
export TOOL=/N/project/MicrobiomeHealth/pregnant/bin/enaBrowserTools/python3/enaDataGet

bash /N/project/MicrobiomeHealth/pregnant/scripts/15_enaData.sh
