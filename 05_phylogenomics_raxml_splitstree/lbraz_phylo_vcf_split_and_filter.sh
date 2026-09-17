## the default GATK genotyping script is using the default filtering
## of GATK, and retains next to SNPs also indels. However, the indels are not 
## compatible with the method of Fre to convert the SNPs to some kind of SNP-only
## fasta file ==> only continue with **SNPs only** and follow a more 
## stringent procedure as given in Jara et al. 2023

## software settings
module load BCFtools
module load SAMtools
module load GATK
plink2=/user/antwerpen/205/vsc20587/data/software/plink_2.00/plink2

## parameter settings
ref_genome=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta
vcf_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/

prefix=phylo.SuSL
prefix=phylo.sWGA_baits
prefix=phylo.sWGA_digest


## rename the sample names and harmonise. Rename the vcf file 
## name and index 
cd ${vcf_dir}
bcftools query -l ${prefix}.filtered.snps.vcf.gz > ${prefix}.sample_names_orig.txt
cp ${prefix}.sample_names_orig.txt ${prefix}.sample_names.txt
sed -i 's/\/user\/antwerpen\/205\/vsc20587\/aitg_scratch\/jcdujardin\/lbraz_susl_swga\///g' ${prefix}.sample_names.txt
awk '{ if ($0 ~ /^0/) print "105561-001-" $0; else print $0 }' ${prefix}.sample_names.txt > ${prefix}.sample_names_new.txt
paste ${prefix}.sample_names_orig.txt ${prefix}.sample_names_new.txt > ${prefix}.sample_names_replace.txt
bcftools reheader --samples ${prefix}.sample_names_replace.txt ${prefix}.filtered.snps.vcf.gz -o ${prefix}.filtered.renamed.snps.vcf.gz

gatk IndexFeatureFile --input ${prefix}.filtered.renamed.snps.vcf.gz


## stringent filtering on the SNP vcf file: QD > 20 is based on histogram
## made of all QD values of the vcf file. Only one peak between QD 20 and 
## 40 // QUAL < 40: based on publication Jara 2023 (fre)
gatk VariantFiltration \
-V ${vcf_dir}/${prefix}.filtered.renamed.snps.vcf.gz \
-filter "QD < 20.0" --filter-name "QD20" \
-filter "QUAL < 40.0" --filter-name "QUAL40" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-O ${vcf_dir}/${prefix}.filtered_stringent_added.renamed.snps.vcf.gz

gatk SelectVariants \
-R $ref_genome \
-V ${vcf_dir}/${prefix}.filtered_stringent_added.renamed.snps.vcf.gz \
--exclude-filtered true \
-O ${vcf_dir}/${prefix}.filtered_stringent.renamed.snps.vcf.gz

zcat ${vcf_dir}/${prefix}.filtered_stringent.renamed.snps.vcf.gz | grep -v "#" | wc


## do different selection on the number of missing SNPs allowed 
## (probably only needed for sWGA samples). Output is written to 
## file plink2.smiss in the working directory (cannot be changed?)
${plink2}  --missing sample-only --vcf ${vcf_dir}/${prefix}.filtered_stringent.renamed.snps.vcf.gz  --allow-extra-chr --threads 4
mv ${vcf_dir}/plink2.smiss ${vcf_dir}/${prefix}.plink2.smiss





