#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=10:00:00

## input parameters
module load Java
beagle_jar=/user/antwerpen/205/vsc20587/data/software/beagle/beagle.22Jul22.46e.jar
beagle_vcf2beagle_jar=/user/antwerpen/205/vsc20587/data/software/beagle/vcf2beagle.jar
# java -jar ${beagle_jar}


## for only the lineage 1 samples
# java -jar ${beagle_jar} \
#     gt=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz \
#     out=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.beagle \
#     nthreads=28


## including the lineage 2 samples
java -jar ${beagle_jar} \
    gt=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/phylo.SuSL.filtered_stringent.renamed2.fraction0.95.lbraz.snps.complete.vcf.gz \
    out=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/phylo.SuSL.filtered_stringent.renamed2.fraction0.95.lbraz.snps.complete.beagle \
    nthreads=28


