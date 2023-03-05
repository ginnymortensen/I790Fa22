#!/bin/bash

#cd /N/project/GutD/GutDB/IBS/PRJEB42304/Round2

#!bin/bash

#Created by Genevieve Mortensen, adapted from Jamie Canderan

#cd /N/project/MicrobiomeHealth/pregnant/scripts

#Stamplename=$(head -n $SLURM_ARRAY_TASK_ID /N/project/MicrobiomeHealth/pregnant/data/sequence/Lin-data/PRJEB13870/PRJEB13870_samples.txt | tail -n 1)
#n3 run_batch.py cd1 0 48 48

import sys, os

# range of arg1 to arg2, eg run_batch.py cd1 1 3 runs cd1 1,2,3
# run_batch.py project start_job end_job runtime_in_hours
files = os.listdir(os.path.join("/N", "project", "MicrobiomeHealth", "pregnant", "data", "sequence", "Lin-data", "PRJEB13870"))
#figure out how to go through files
for i in files:
    if os.path.exists("runqueue"):
        os.remove("runqueue")
    f = open("runqueue", "a")
    f.write("#!/bin/bash\n")
    f.write("#SBATCH -J rq_%s\n" % (i))
    f.write("#SBATCH -p general\n")
    f.write("#SBATCH --mail-type=ALL\n")
    f.write("#SBATCH --mail-user=gamorten@iu.edu\n")
    f.write("#SBATCH --mem=128G\n")
    f.write("#SBATCH --nodes=1\n")
    f.write("#SBATCH --ntasks=1\n")
    f.write("#SBATCH --cpus-per-task=24\n")
    f.write("#SBATCH --time=30:00:00\n")
    f.write("bash /N/project/MicrobiomeHealth/pregnant/scripts/08_humann_usage.sh --i")
#modify to support command line vars ^
    f.close()
    os.system("sbatch runqueue")
#bash /N/project/MicrobiomeHealth/pregnant/scripts/08_humann_usage.sh $Samplename
