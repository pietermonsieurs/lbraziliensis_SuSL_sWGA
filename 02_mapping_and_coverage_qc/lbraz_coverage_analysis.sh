#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=10:50:00

/user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_analysis.py ${cov_file}

## run in a for loop with sbatch, and with the slurm 
## parameters in the header of the python script
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/
# for cov_file in *.depth; do sbatch --export=cov_file=${PWD}/${cov_file} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_analysis.sh; done
