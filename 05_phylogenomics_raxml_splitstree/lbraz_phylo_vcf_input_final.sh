module load BioTools

## create output directory to save the final vcf files
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/
mkdir final
out_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/

## step 1: start from the overall vcf file (containing many genomes, also non Lbraz genomes) 
## in /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo

bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.snps.vcf.gz
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.9.snps.vcf.gz

bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.snps.vcf.gz | grep "LFA"
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.9.snps.vcf.gz | grep "LFA"

## extract the samples where only the Lbraz genomes are retained + the clonal strains
## from the paper of Senne have already been removed, but remove sample 104 (liansoni)
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated 
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz > ${out_dir}/samples.csv
vi ${out_dir}/samples.csv ## add samples LFA-CU-009_SuSL_baits and LFA-CU-024_SuSL_none, adn remove LFA-CU-104_SuSL_none


## subset overall vcf file (containing all SNPs) to only the subset of samples selected. The raw
## vcf file contains 2126280 (both 0.5 and 0.90 fraction, only the sample are different between both files)
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo
bcftools view -S ${out_dir}/samples.csv phylo.SuSL.filtered_stringent.renamed2.fraction0.9.snps.vcf.gz -Oz -o ${out_dir}/phylo.vcf.gz

## do filtering of the vcf file, to remove those SNPs which show no variation
## over the different samples
cd ${out_dir}

## check the amount of SNPs which are for *all* samples predicted as 0/0 or 
## predicted as 0/0. Afterwards, remove them and check whether the counts is
## correct (should be ~ 2126280 minus 35320 + 110). Also, check whehther the 
## list is already filtered to only contain biallelic SNPs
bcftools view -e 'GT!="0/0"' phylo.vcf.gz | wc  ## count = 35320
bcftools view -e 'GT!="1/1"' phylo.vcf.gz | wc ## count = 110
bcftools view --min-alleles 2 --max-alleles 2 phylo.vcf.gz | wc ## count = 2035170 (~ 80.000 removed)

bcftools view \
    -i 'GT!="0/0" && GT!="1/1"' \
    --min-alleles 2 --max-alleles 2 \
    phylo.vcf.gz \
    -Oz -o phylo.biallelic.vcf.gz 

zcat phylo.biallelic.vcf.gz  | wc  ## count = 2000899

## only take into account the SNPs which are predicted in all samples, so 
## only complete measurements
nr_of_samples=$(bcftools query -l phylo.biallelic.vcf.gz | wc -l)
bcftools view phylo.biallelic.vcf.gz --types snps --min-ac ${nr_of_samples} -Oz -o phylo.biallelic.complete.vcf.gz
zcat phylo.biallelic.complete.vcf.gz | wc ## count = 77982 --> in line with previous analysis

## optional: remove the "bad" SureSelect samples from the vcf file and 
## repeat the above procedure














