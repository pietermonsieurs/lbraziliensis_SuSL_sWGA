#!/usr/bin/bash 

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=10:00:00

module load Python
module load SciPy-bundle

echo "cov_file --> ${cov_file}"
/user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_drugs_coverage_all_genes_parsing.py ${cov_file}

## run in a for loop
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/
# for cov_file in *paired.cov; do sbatch --export=cov_file=${PWD}/${cov_file} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_drugs_coverage_all_genes_parsing.slurm; done

## after running the coverage for all the files, concat the different 
## files
# files=(*paired.cov.summary)
# for cov_file in "${files[@]}"; do
#     cat "$cov_file"
#     echo    # Add a newline character between files
# done > coverage_per_gene.cov.summary
   