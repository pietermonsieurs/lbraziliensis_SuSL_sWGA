#!/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=56
#SBATCH --time=70:00:00
#SBATCH --job-name=RAxML
#SBATCH -A ap_itg_mpu


## modules required 
module load RAxML-NG 

## software components
vcf2fasta=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/GATK_vcf2fasta.py
vcf2phylip=/user/antwerpen/205/vsc20587/data/software/vcf2phylip/vcf2phylip.py


## input parameters
# vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated/
# vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/
# vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/
vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/

## file prefix
# file_prefix=${vcf_dir}/phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated
# file_prefix=${vcf_dir}/phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.clean
# file_prefix=${vcf_dir}/phylo.biallelic.complete ## 77880
file_prefix=${vcf_dir}/phylo.SuSL.filtered_stringent.renamed2.fraction0.95.snps.lbraz_only

## parameter settings
threads=56
# type=SuSL
# type=sWGA_baits
# fraction=0.5


## convert the vcf-file to a fasta file using the vcf2phylip approach. This will give an indepdent
## conformation compared to using a non-IUPAC code approach
# ${vcf2fasta} ${file_prefix}.vcf.gz
$vcf2phylip  -i ${file_prefix}.vcf.gz \
    --output-folder $vcf_dir \
    --output-prefix ${file_prefix} \
    -m 4 \
    -f


if [ ! -f "${file_prefix}.phy" ]; then
    echo "${file_prefix}.phy does not exist."
    ln -s ${file_prefix}.phy.min4.phy ${file_prefix}.phy
fi

## run RAxML on the fasta file
raxml-ng --check --msa ${file_prefix}.min4.fasta --model GTR+G --prefix ${file_prefix}.T1
raxml-ng --parse --msa ${file_prefix}.min4.fasta --model GTR+G --prefix ${file_prefix}.T2
raxml-ng --search1 --msa ${file_prefix}.T2.raxml.rba --model GTR+G --prefix ${file_prefix}.T3 --threads $threads --seed 2 


## RAxML, run with bootstrapping
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