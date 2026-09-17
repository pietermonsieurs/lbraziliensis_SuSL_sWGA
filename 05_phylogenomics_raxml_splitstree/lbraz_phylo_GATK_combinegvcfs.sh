#!/bin/bash -l 

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=20:00:00
#SBATCH -A ap_itg_mpu

module load GATK 

## combine all the lbraziliensis sWGA and SureSelect
## samples

ref_genome_lbraz=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta
gvcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/
# gvcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/

## print all gvcf files with "--variant" prefix to create the
## bash command
cd $gvcf_dir
# for gatk_file in *.gatk.g.vcf; do echo "   --variant \${gvcf_dir}/$gatk_file \\"; done


## run for SuSL 
# variant_file=${gvcf_dir}/gvcf_files.SuSL.list
# gatk CombineGVCFs \
#    -R ${ref_genome_lbraz} \
#    --variant ${variant_file} \
#    -O ${gvcf_dir}/phylo.SuSL.g.vcf.gz

## run for sWGA-baits
# variant_file=${gvcf_dir}/gvcf_files.sWGA_baits.list
# gatk CombineGVCFs \
#    -R ${ref_genome_lbraz} \
#    --variant ${variant_file} \
#    -O ${gvcf_dir}/phylo.sWGA_baits.g.vcf.gz


## run for sWGA-digest
variant_file=${gvcf_dir}/gvcf_files.sWGA_digest.list
gatk CombineGVCFs \
   -R ${ref_genome_lbraz} \
   --variant ${variant_file} \
   -O ${gvcf_dir}/phylo.sWGA_digest.g.vcf.gz


