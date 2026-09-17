## setting for PLINK
plink=/user/antwerpen/205/vsc20587/data/software/plink_1.90/plink
plink2=/user/antwerpen/205/vsc20587/data/software/plink_2.00/plink2
admixture=/user/antwerpen/205/vsc20587/data/software/admixture_linux-1.3.0/admixture

# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/final/

# type=SuSL
# fraction=0.5

## taking into account all samples
# vcf_file=phylo.${type}.filtered_stringent.renamed2.fraction${fraction}.lbraz.snps.vcf.gz
# out_prefix=phylo.${type}.filtered_stringent.renamed2.fraction${fraction}.lbraz.snps

## taking into account only the complete SNPs, which means that
## all SNP should be predicted for every sample, or the SNP is removed

# vcf_file=phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz
# out_prefix=phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated

# vcf_file=phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.clean.vcf.gz
# out_prefix=phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.clean
vcf_file=phylo.biallelic.complete.vcf.gz
out_prefix=plink/phylo.biallelic.complete

## convert vcf file to the PLINK formats which 
## consists of three files (.bed, .fam, .bim)
$plink2 --vcf $vcf_file \
    --allow-extra-chr \
    --out ${out_prefix} \
    --make-bed \
    --max-alleles 2 \
    --threads 1 \
    --set-all-var-ids @:# \
    --maf 0.05

## do LD Pruning
$plink2 --indep-pairwise 50 5 0.5 \
    --bfile ${out_prefix} \
    --out ${out_prefix} \
    --allow-extra-chr \
    --threads 1 

## do Selection based on LD pruning results obtained
## in the previous step
$plink2 --bfile ${out_prefix} \
    --extract ${out_prefix}.prune.in \
    --allow-extra-chr \
    --out ${out_prefix}.ldpruned \
    --threads 1 \
    --make-bed

## do PCA analysis using the LD pruned file
$plink2 --bfile ${out_prefix}.ldpruned \
    --pca biallelic-var-wts 5 \
    --out ${out_prefix}.ldpruned \
    --allow-extra-chr \
    --threads 1 

awk '{$1="0";print $0}' ${out_prefix}.ldpruned.bim > ${out_prefix}.ldpruned.bim.tmp
mv ${out_prefix}.ldpruned.bim ${out_prefix}.bim.source
mv ${out_prefix}.ldpruned.bim.tmp ${out_prefix}.ldpruned.bim

$admixture ${out_prefix}.ldpruned.bed 5  > test.log
