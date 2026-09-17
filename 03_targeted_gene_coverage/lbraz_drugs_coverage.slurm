#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=00:30:00

module load BioTools

## bam_file test
# bam_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/105561-001-039.mapq30.removedups.proper_paired.bam
cov_file=${bam_file/.bam/.drugs.cov}

# bed_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/Lbraziliensis_drugresistance.bed
# bed_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/Lbraziliensis_drugs_tf_virulence.bed
bed_file=

## run samtools depth based on the bam-file imported via export or 
## via atools
samtools depth -a -b ${bed_file} ${bam_file} > ${cov_file}


## loop over all bam_files
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/
# for bam_file in *.bam; do sbatch --export=bam_file=${PWD}/${bam_file} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_drugs_coverage.slurm; done