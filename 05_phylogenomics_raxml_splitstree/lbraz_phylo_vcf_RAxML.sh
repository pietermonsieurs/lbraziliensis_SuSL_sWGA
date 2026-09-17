#!/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=8
#SBATCH --time=52:00:00
#SBATCH --job-name=RAxML
#SBATCH -A ap_itg_mpu



## modules required 
module load BCFtools
module load RAxML-NG 

## software components
vcf2fasta=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/GATK_vcf2fasta.py


## input parameters
vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/

## initial prefix - without "2" after renamed
vcf_prefix_init=phylo.${type}.filtered_stringent.renamed
vcf_src=${vcf_dir}/${vcf_prefix_init}.snps.vcf.gz

## vcf prefix to be used for RAxML
vcf_prefix=phylo.${type}.filtered_stringent.renamed2


## parameter settings
threads=8
# type=SuSL
# type=sWGA_baits
# fraction=0.5

## define file names, and create subset of the overall
## vcf file 
sample_file=${vcf_dir}/subset_remove.phylo.${type}.fraction${fraction}.txt
vcf_file_sub=${vcf_dir}/${vcf_prefix_init}.fraction${fraction}.snps.vcf.gz
bcftools view \
    --samples-file ^${sample_file} \
    -Oz -o ${vcf_file_sub} \
    ${vcf_src}



## rename to interpretable names
file_prefix=${vcf_dir}/${vcf_prefix}.fraction${fraction}.snps
rename_file=${vcf_dir}/subset.phylo.${type}.fraction${fraction}.rename.txt
bcftools reheader \
    --samples ${rename_file} \
    -o ${file_prefix}.vcf.gz \
    ${vcf_file_sub} 


## convert the vcf-file to a fasta file following the python
## script of Fre
${vcf2fasta} ${file_prefix}.vcf.gz

## run RAxML on the fasta file
raxml-ng --check --msa ${file_prefix}.vcf.gz.fa --model GTR+G --prefix ${file_prefix}.T1
raxml-ng --parse --msa ${file_prefix}.vcf.gz.fa --model GTR+G --prefix ${file_prefix}.T2
raxml-ng --search1 --msa ${file_prefix}.T2.raxml.rba --model GTR+G --prefix ${file_prefix}.T3 --threads $threads --seed 2 


## RAxML, run with qaqbootstrapping
raxml-ng --bootstrap --msa ${file_prefix}.T2.raxml.rba --prefix ${file_prefix}.T4 --threads $threads --seed 2 --bs-trees 100

## RAxML add bootstrapping values on the best scoring tree
raxml-ng --support --tree ${file_prefix}.T3.raxml.bestTree --bs-trees ${file_prefix}.T4.raxml.bootstraps --prefix ${file_prefix}.T5 --threads $threads 


cat ${file_prefix}*bootstraps > ${file_prefix}.T4.raxml.merged.bootstraps
raxml-ng --support --tree ${file_prefix}.T3.raxml.bestTree --bs-trees ${file_prefix}.T4.raxml.merged.bootstraps --prefix ${file_prefix}.T5 --threads $threads 


## run over the different parameter settings. run the for loop and 
## start up different processes in parallel. For SureSelect the 
## fraction of 0.90 and 0.95 will be the same
# types=("SuSL" "sWGA_baits" "sWGA_digest")
# types=("sWGA_baits" "sWGA_digest")
# fractions=(0.5 0.8 0.9 0.95)
# for type in "${types[@]}"; do
#     for fraction in "${fractions[@]}"; do
#          sbatch --export=fraction=${fraction},type=${type} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_vcf_RAxML.sh
#     done
# done


# types=("SuSL" "sWGA_baits" "sWGA_digest")
# fractions=(0.5 0.95)
# for type in "${types[@]}"; do
#     for fraction in "${fractions[@]}"; do
#          sbatch --export=fraction=${fraction},type=${type} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_phylo_vcf_RAxML.sh
#     done
# done