#!/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=8
#SBATCH --time=71:00:00
#SBATCH -A ap_itg_mpu

## read in the K-value using the atools module
## test value: K=2
module purge
module load calcua/2024a
module load atools

source <(aenv --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/K_values.csv)
echo $K

## settings for the software to be used
admixture=/user/antwerpen/205/vsc20587/data/software/admixture_linux-1.3.0/admixture
cross_validation=100

## input parameters of the .vcf file and output 
threads=8
# out_prefix=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_elife/plink/genomes_elife.outbreak.ldpruned
echo ${out_prefix}

cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/plink/
$admixture -j${threads} --cv=${cross_validation} ${out_prefix}.bed $K  > ${out_prefix}.K${K}.log


## create file with differnet values of K
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink
# for K in {2..20}; do echo $K; done > K_values.csv
# echo $PWD/K_values.csv
# vi K_values.csv
# module load atools
# for ld_pruned_file in *ldpruned.bed; do out_prefix=$(basename -- $ld_pruned_file .bed); echo $out_prefix; sbatch --array $(arange --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/K_values.csv) --export=out_prefix=${PWD}/${out_prefix} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_plink_admixture.slurm; done

## same approach but now using the "complete" vcf files, where every SNP 
## should be genotyped in every samples
# module load atools
# for ld_pruned_file in *complete.ldpruned.bed; do out_prefix=$(basename -- $ld_pruned_file .bed); echo $out_prefix; sbatch --array $(arange --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/K_values.csv) --export=out_prefix=${PWD}/${out_prefix} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_plink_admixture.slurm; done

## same approach but for the final analysis. This only contains one bed file
## so looping not need, but keep it just in case
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/plink/
# module load atools
# for ld_pruned_file in *complete.ldpruned.bed; do out_prefix=$(basename -- $ld_pruned_file .bed); echo $out_prefix; sbatch --array $(arange --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/K_values.csv) --export=out_prefix=${PWD}/${out_prefix} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_plink_admixture.slurm; done

## do the same but now for the sWGA samples only
# module purge
# module load calcua/2024a
# module load atools
# for ld_pruned_file in phylo.sWGA*complete.ldpruned.bed; do out_prefix=$(basename -- $ld_pruned_file .bed); echo $out_prefix; sbatch --array $(arange --no_sniffer --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/K_values.csv) --export=out_prefix=${PWD}/${out_prefix} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_plink_admixture.slurm; done



## filter out the CV values in bash, or use the script
## lbraz_phylo_plink_admixture_parseCV.py
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/plink/
# cat *.log | grep "CV error" |  awk -F"[():=]" '{print $3, $5}' > CV_values.csv





