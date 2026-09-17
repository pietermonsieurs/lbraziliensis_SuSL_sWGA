module load BioTools

## create two new directories removing the clonal isolates (phylo_curated) and
## additionally also remove suspicous SuSl samples (phylo_curated_clean)
mkdir /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated
mkdir /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean

## copy the vcf file containging "complete" SNP profile to phylo_curated
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated
mv ../phylo/plink/phylo.sWGA_digest.filtered_stringent.renamed2.fraction0.95.lbraz.snps.complete.vcf.gz ./

## create a file with all samples and remove the clonal isolates from them
## based on the file of Senne: Lbraziliensis.data_Senne.clonal_isolates.xlsx
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.vcf.gz > samples_curated.txt
vi samples_curated.txt
bcftools view -Oz -S samples_curated.txt phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.vcf.gz -o phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz


## copy the curated file to the curated_clean directory, to remove the 
## bad quality sureselect files 
cp phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz ../phylo_curated_clean
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz > samples_curated_clean.txt
bcftools view -Oz -S samples_curated_clean.txt phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz -o phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.clean.vcf.gz
