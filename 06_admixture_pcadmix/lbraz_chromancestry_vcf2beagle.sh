## after running beagle, you get a simplified vcf file containing
## the phased haplotype: lbraz_chromancestry_beagle.sh
## This one needs to be converted to the beagle file 
## format with one nucleotide per haplotype per species
module load Java
module load BioTools ## for bcftools
beagle_vcf2beagle_jar=/user/antwerpen/205/vsc20587/data/software/beagle/vcf2beagle.jar
pcadmix=/user/antwerpen/205/vsc20587/data/software/PCAdmix/PCAdmix3_linux
pcadmix=/Users/pmonsieurs/programming/software/PCAdmix/PCAdmix3_macOSX

## simple test script to check the software. needs to be
## run on a UNZIPPED vcf file
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/
gunzip phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.beagle.vcf.gz
cat phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.beagle.vcf | java -jar ${beagle_vcf2beagle_jar} m pcadmix/test

## create different populations (INP,PAU,HUP), and keep one populations with 
## all the "unknown" samples (SuSL + adm wgs samples) and check
## whether they are admixed. THe populations of WGS are summarized in the 
## excel file Lbraziliensis.data_Senne.clonal_isolates_populations.xlsx
cd pcadmix
vi pau.list
vi inp.list
vi hup.list

## adm list. Use the list as pasted from the excel, but also add some
## negative controls which are *NOT* admixture populiations but come from
## INP, PAU and HUP (same set chosen as publicatoin Senne)
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/
vi adm_wgs.list ## paste the data from the excel
vi adm_negcontrol.list  ## same samples as Senne in paper
bcftools query -l phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.vcf.gz | grep "SuSL" > SuSL.list
cat adm_negcontrol.list adm_wgs.list SuSL.list > adm.list
cp adm.list pcadmix/


## make subset of the vcf file using bcftools. first convert the 
## beagle output to a bgzipped file and index with tabix
src_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/phylo.SuSL.filtered_stringent.renamed2.fraction0.5.lbraz.snps.complete.curated.beagle.vcf
bgzip ${src_file}
bcftools view -Oz ${src_file} -o ${src_file}.bgz
tabix ${src_file}.gz

cd pcadmix
bcftools view -Ov --samples-file pau.list ${src_file}.gz > pau.vcf
bcftools view -Ov --force-samples --samples-file inp.list ${src_file}.gz > inp.vcf
bcftools view -Ov --force-samples --samples-file hup.list ${src_file}.gz > hup.vcf
bcftools view -Ov --force-samples --samples-file adm.list ${src_file}.gz > adm.vcf


## convert the vcf file with phase genotypes to a beagle format
## which can be used as input for pcadmix
cat pau.vcf | java -jar ${beagle_vcf2beagle_jar} m pau
cat inp.vcf | java -jar ${beagle_vcf2beagle_jar} m inp
cat hup.vcf | java -jar ${beagle_vcf2beagle_jar} m hup
cat adm.vcf | java -jar ${beagle_vcf2beagle_jar} m adm
gunzip hup.bgl.gz inp.bgl.gz pau.bgl.gz adm.bgl.gz

## run PCadmix
$pcadmix -anc pau.bgl inp.bgl hup.bgl -adm adm.bgl -w 30


######### PER CHROMOSOME ###########

## do a per-chromosome analysis. First make a list of all chromosomes
## and then loop over it to make a per-chrom beagle vcf-file
chrom_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/pcadmix/chroms.csv
vi ${chrom_file}

## conver the vcf file again to a bgzipped vcf-file and index 
## the gizpped file
bcftools view -Ob pau.vcf -o pau.vcf.gz
bcftools view -Ob inp.vcf -o inp.vcf.gz
bcftools view -Ob hup.vcf -o hup.vcf.gz
bcftools view -Ob adm.vcf -o adm.vcf.gz

bcftools index pau.vcf.gz
bcftools index inp.vcf.gz
bcftools index hup.vcf.gz
bcftools index adm.vcf.gz

## split up on a per-chromosome basis
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/pcadmix
while IFS= read -r chrom; do
    echo "Processing chromosome: ${chrom}"
    bcftools view -Ov -r ${chrom} pau.vcf.gz -o per_chrom/pau.${chrom}.vcf
    bcftools view -Ov -r ${chrom} inp.vcf.gz -o per_chrom/inp.${chrom}.vcf
    bcftools view -Ov -r ${chrom} hup.vcf.gz -o per_chrom/hup.${chrom}.vcf
    bcftools view -Ov -r ${chrom} adm.vcf.gz -o per_chrom/adm.${chrom}.vcf
done < ${chrom_file}

## convert to beagle format
cd per_chrom
while IFS= read -r chrom; do
    echo "convert2beagle format for chromosome: ${chrom}";
    cat pau.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m pau.${chrom};
    cat inp.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m inp.${chrom};
    cat hup.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m hup.${chrom};
    cat adm.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m adm.${chrom};
    # $pcadmix -anc pau.bgl inp.bgl hup.bgl -adm adm.bgl -w 30
done < ${chrom_file}


## unzipping the bgl.gz
while IFS= read -r chrom; do
    echo "unzipping beagle for chromosome: ${chrom}";
    gunzip pau.${chrom}.bgl.gz
    gunzip inp.${chrom}.bgl.gz
    gunzip hup.${chrom}.bgl.gz
    gunzip adm.${chrom}.bgl.gz
    # $pcadmix -anc pau.bgl inp.bgl hup.bgl -adm adm.bgl -w 30
done < ${chrom_file}

pcadmix=/user/antwerpen/205/vsc20587/data/software/PCAdmix/PCAdmix3_linux
while IFS= read -r chrom; do
    echo "PCadmix for chromosome: ${chrom}";
    $pcadmix -anc pau.${chrom}.bgl inp.${chrom}.bgl hup.${chrom}.bgl -adm adm.${chrom}.bgl -w 30 -o pcadmix.${chrom}
done < ${chrom_file}





################ INCLUDE LINEAGE2 #################

## add an additional population (lineage 2 from Lbraziliensis) which are
## samples PER163, CUM663 and CUM555, and add CU09 and CU024 to check 
## whether sample 024 is a hybrid. 

## same parameter settings as above
module load Java
module load BioTools ## for bcftools
beagle_vcf2beagle_jar=/user/antwerpen/205/vsc20587/data/software/beagle/vcf2beagle.jar
pcadmix=/user/antwerpen/205/vsc20587/data/software/PCAdmix/PCAdmix3_linux
pcadmix=/Users/pmonsieurs/programming/software/PCAdmix/PCAdmix3_macOSX

## create new directory inside the plink directory to store the PCadmix 
## results
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/
mkdir pcadmix
cd pcadmix

## create a new list containing the lineage 2 samples
vi lin2.list ## add PER163, CUM663 and CUM555

##, and create a new SuSL.list (now containing also 
## sample 009 and 024), and recreate adm.list
src_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/phylo.SuSL.filtered_stringent.renamed2.fraction0.95.lbraz.snps.complete.beagle.vcf
bcftools query -l ${src_file}.gz | grep "SuSL" > SuSL.list
vi SuSL.list ## remove sample 104, as this in Liansoni!!
cat adm_negcontrol.list adm_wgs.list SuSL.list > adm.list




## start from the file containing all lbraziliensis strains and which 
## are also "complete" measurements
# bgzip ${src_file}
# bcftools view -Oz ${src_file} -o ${src_file}.gz
tabix ${src_file}.gz


## create subset of the beagle vcf file in order to have different
## subpopulations + the admixture format
bcftools view -Ov --samples-file pau.list ${src_file}.gz > pau.vcf
bcftools view -Ov --force-samples --samples-file inp.list ${src_file}.gz > inp.vcf
bcftools view -Ov --force-samples --samples-file hup.list ${src_file}.gz > hup.vcf
bcftools view -Ov --force-samples --samples-file lin2.list ${src_file}.gz > lin2.vcf
bcftools view -Ov --force-samples --samples-file adm.list ${src_file}.gz > adm.vcf

## convert the vcf file with phase genotypes to a beagle format
## which can be used as input for pcadmix
cat pau.vcf | java -jar ${beagle_vcf2beagle_jar} m pau
cat inp.vcf | java -jar ${beagle_vcf2beagle_jar} m inp
cat hup.vcf | java -jar ${beagle_vcf2beagle_jar} m hup
cat lin2.vcf | java -jar ${beagle_vcf2beagle_jar} m lin2
cat adm.vcf | java -jar ${beagle_vcf2beagle_jar} m adm
gunzip hup.bgl.gz inp.bgl.gz pau.bgl.gz lin2.bgl.gz adm.bgl.gz

## run PCadmix
$pcadmix -anc pau.bgl inp.bgl hup.bgl lin2.bgl -adm adm.bgl -w 30


## do a per-chromosome analysis. First make a list of all chromosomes
## and then loop over it to make a per-chrom beagle vcf-file
chrom_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo_curated_clean/pcadmix/chroms.csv
vi ${chrom_file}

## conver the vcf file again to a bgzipped vcf-file and index 
## the gizpped file
bcftools view -Ob pau.vcf -o pau.vcf.gz
bcftools view -Ob inp.vcf -o inp.vcf.gz
bcftools view -Ob hup.vcf -o hup.vcf.gz
bcftools view -Ob lin2.vcf -o lin2.vcf.gz
bcftools view -Ob adm.vcf -o adm.vcf.gz

bcftools index pau.vcf.gz
bcftools index inp.vcf.gz
bcftools index hup.vcf.gz
bcftools index lin2.vcf.gz
bcftools index adm.vcf.gz

## split up on a per-chromosome basis
cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/plink/pcadmix
mkdir per_chrom
while IFS= read -r chrom; do
    echo "Processing chromosome: ${chrom}"
    bcftools view -Ov -r ${chrom} pau.vcf.gz -o per_chrom/pau.${chrom}.vcf
    bcftools view -Ov -r ${chrom} inp.vcf.gz -o per_chrom/inp.${chrom}.vcf
    bcftools view -Ov -r ${chrom} hup.vcf.gz -o per_chrom/hup.${chrom}.vcf
    bcftools view -Ov -r ${chrom} lin2.vcf.gz -o per_chrom/lin2.${chrom}.vcf
    bcftools view -Ov -r ${chrom} adm.vcf.gz -o per_chrom/adm.${chrom}.vcf
done < ${chrom_file}

## convert to beagle format
cd per_chrom
while IFS= read -r chrom; do
    echo "convert2beagle format for chromosome: ${chrom}";
    cat pau.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m pau.${chrom};
    cat inp.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m inp.${chrom};
    cat hup.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m hup.${chrom};
    cat lin2.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m lin2.${chrom};
    cat adm.${chrom}.vcf | java -jar ${beagle_vcf2beagle_jar} m adm.${chrom};
    # $pcadmix -anc pau.bgl inp.bgl hup.bgl -adm adm.bgl -w 30
done < ${chrom_file}


## unzipping the bgl.gz
while IFS= read -r chrom; do
    echo "unzipping beagle for chromosome: ${chrom}";
    gunzip pau.${chrom}.bgl.gz
    gunzip inp.${chrom}.bgl.gz
    gunzip hup.${chrom}.bgl.gz
    gunzip lin2.${chrom}.bgl.gz
    gunzip adm.${chrom}.bgl.gz
    # $pcadmix -anc pau.bgl inp.bgl hup.bgl -adm adm.bgl -w 30
done < ${chrom_file}

pcadmix=/user/antwerpen/205/vsc20587/data/software/PCAdmix/PCAdmix3_linux
while IFS= read -r chrom; do
    echo "PCadmix for chromosome: ${chrom}";
    $pcadmix -anc pau.${chrom}.bgl inp.${chrom}.bgl hup.${chrom}.bgl lin2.${chrom}.bgl -adm adm.${chrom}.bgl -w 30 -o pcadmix.${chrom}
done < ${chrom_file}

