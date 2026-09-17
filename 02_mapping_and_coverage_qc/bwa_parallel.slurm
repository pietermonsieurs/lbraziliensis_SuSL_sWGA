#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=10:00:00
#SBATCH -A ap_itg_mpu

## load modules
module load BWA
module load SAMtools
module load Java

## define variables
export THREADS=28
export SEED=50

## BWA_DIR
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/subsample_permix/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/subsample_overall/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210714/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210714/subsample_permix/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20220503/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_2022/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_tropica_clinical/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20230116/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_elife/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_plosntds/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_aethiopica/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_swga_2023/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_aethiopica_skinslit/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_aethiopica_skinslit/amber_extragenomes/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/artificial/bwa/
BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/lainsoni/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_somalileish/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_tropica_morocco/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_tropica_morocco/artificial_mixes/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_tropica_morocco/somy_laeth/
# BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_aethiopica_skinslit2/

## REF GENOME
# export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/GCF_000227135.1_ASM22713v2_genomic.fna
# export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/Leishmania_donovani_16Nov2015beta.fa
export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta
# export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-58_LtropicaL590_Genome.fasta
# export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-56_LaethiopicaL147_Genome.fasta
# REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/GCA_014139745.1_CDC_Ltropica216-162_v1_genomic.fna


## SOFTWARE PARAMS
export PICARD_JAR=/data/antwerpen/205/vsc20587/software/picard/picard.jar
export PICARD_BIN="java -jar ${PICARD_JAR}"
export mapq_cutoff=30


### index reference genomes
## indexing already performed in previous analysis
# bwa index $REF_GENOME

## create the necessary filenames based on te input information
# fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/HCCHFDSX2_104509-001-003_GCCAAGAC_L001_R1.fastq.gz
# fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/HCCHFDSX2_104509-001-001_AACGTGAT_L002_R1.fastq.gz
# fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/elife_fastq/ERR895175_1.fastq.gz

echo "before substituions: ${fastq_file_R1}"
## depending on which sequencing file, you have to choose either R2 or R3
# fastq_file_R2=${fastq_file_R1/_R1.fastq.gz/_R2.fastq.gz}
# fastq_file_R2=${fastq_file_R1/_R1.fastq.gz/_R3.fastq.gz}
fastq_file_R2=${fastq_file_R1/_1.fastq.gz/_2.fastq.gz}
# fastq_file_R2=${fastq_file_R1/_R1_001.fastq.gz/_R2_001.fastq.gz}

## file prefix - depening on naming convention
# file_prefix=${fastq_file_R1%_L00*_R1.fastq.gz}
# file_prefix=${fastq_file_R1%_R1.fastq.gz}
file_prefix=${fastq_file_R1%_1.fastq.gz}
# file_prefix=${fastq_file_R1%_R1_001.fastq.gz}

file_prefix=${file_prefix##*/}
bam_file_prefix=${BWA_DIR}/${file_prefix}

echo $fastq_file_R1
echo $fastq_file_R2
echo $file_prefix
echo $bam_file_prefix

### run BWA with increased seed 
bwa mem \
    -R "@RG\tID:${file_prefix}\tSM:${file_prefix}\tPL:ILLUMINA" \
    -k $SEED \
    -t $THREADS \
    $REF_GENOME \
    $fastq_file_R1 $fastq_file_R2 | \
    samtools sort -@$THREADS -o ${bam_file_prefix}.bam
samtools index ${bam_file_prefix}.bam
samtools flagstat -@$THREADS ${bam_file_prefix}.bam > ${bam_file_prefix}.flagstat


### selection on mapping quality ###
samtools view -@ $THREADS -bq $mapq_cutoff ${bam_file_prefix}.bam > ${bam_file_prefix}.mapq${mapq_cutoff}.bam
samtools index ${bam_file_prefix}.mapq${mapq_cutoff}.bam
samtools flagstat ${bam_file_prefix}.mapq${mapq_cutoff}.bam > ${bam_file_prefix}.mapq${mapq_cutoff}.flagstat


### remove duplicate reads ### 
$PICARD_BIN MarkDuplicates REMOVE_DUPLICATES=true I=${bam_file_prefix}.mapq${mapq_cutoff}.bam O=${bam_file_prefix}.mapq${mapq_cutoff}.removedups.bam M=${bam_file_prefix}.mapq${mapq_cutoff}.markdups_metrics.txt
samtools index ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.bam
samtools flagstat ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.bam > ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.flagstat


### select only proper paired reads ###
samtools view -@$THREADS -bf 0x2 ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.bam > ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.proper_paired.bam 
samtools index ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.proper_paired.bam 
samtools flagstat ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.proper_paired.bam > ${bam_file_prefix}.mapq${mapq_cutoff}.removedups.proper_paired.flagstat




#### run using different sbatch commands ####

# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210714/
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20220503
# for fastq_file_R1 in  *R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

#### run for the tropica genomes - clinical WGS ####
# cd /user/antwerpen/205/vsc20587/aitg_data/jcdujardin/LeishShield_wgs_morocco_20220301/
# fastq_dir=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/LeishShield_wgs_morocco_20220301/
# for fastq_file_R1 in ${fastq_dir}/*R1.fastq.gz; do sbatch --export=fastq_file_R1=${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

#### run for the tropica genomes - batch 2 - clinical WGS ####
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/genomes_tropica_morocco
# find $PWD -mtime -1 -name "*_R1.fastq.gz" > fastq_files_R1.batch2.csv
# while read -r fastq_file_R1; do sbatch --export=fastq_file_R1=$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm;done < fastq_files_R1.batch2.csv



#### run for the new batch of SureSelect samples from 2023

## create input file
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20230116/
# for sample in {001..003}; do echo $PWD/${sample}_R1.fastq.gz; done > fastq_files_R1.Lbraz.csv
# for sample in {025..030}; do echo $PWD/${sample}_R1.fastq.gz; done >> fastq_files_R1.Lbraz.csv
# for sample in {004..021}; do echo $PWD/${sample}_R1.fastq.gz; done > fastq_files_R1.Laeth.csv
# for sample in {022..024}; do echo $PWD/${sample}_R1.fastq.gz; done > fastq_files_R1.Ldon.csv

## run for different input files, but change always the 
## REF GENOME to the correct setting
# while read -r fastq_file_R1; do sbatch --export=fastq_file_R1=$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm;done < fastq_files_R1.Lbraz.csv
# while read -r fastq_file_R1; do sbatch --export=fastq_file_R1=$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm;done < fastq_files_R1.Ldon.csv
# while read -r fastq_file_R1; do sbatch --export=fastq_file_R1=$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm;done < fastq_files_R1.Laeth.csv

##### run for the eLife samples 
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/elife_fastq/
# for fastq_file_R1 in  *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done


##### run for the PLoS NTD samples 
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/plosntd_fastq/concat
# for fastq_file_R1 in  *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

##### run for the PLoS NTD BPK72 samples 
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/plosntd_fastq/concat
# for fastq_file_R1 in  BPK72*_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

##### run for the Ldon VL9 sample to be used as outlier
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/plosntd_fastq/concat
# for fastq_file_R1 in  VL9*_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

##### run for the three Sri Lanka samples of Franssen et al. 
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/srilanka_fastq
# for fastq_file_R1 in *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

##### run for the other Leish species - accession numbers of infantum, major, tropica
##### obtained from paper of Amber 
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/other_leish_species_fastq/
# for fastq_file_R1 in *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done



## run for the aethiopica samples of Amber

## first batch --> named *R1_001.fastq.gz and *R2_001.fastq.gz
# cd /user/antwerpen/205/vsc20587/aitg_data/jcdujardin/DIORAPHTE_genomes_aethiopica_20210419
# find ~+ -name "*R1_001.fastq.gz" >> ~/scratch/leishmania_susl/data/aethiopica_amber_fastq/fastq_files_batch1.csv
## remove files SintPierre en LEM2357
## adapt script towards *R1_001.fastq.gz and *R2_001.fastq.gz
# while IFS= read -r fastq_file_R1; do sbatch --export=fastq_file_R1=${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done < ~/scratch/leishmania_susl/data/aethiopica_amber_fastq/fastq_files_batch1.csv

## second batch --> named *R1.fastq.gz and R3.fastq.gz
# cd /user/antwerpeqn/205/vsc20587/aitg_data/jcdujardin/DIORAPHTE_genomes_aethiopica_20220523/merged
# ls $PWD/*R1.fastq.gz > ~/scratch/leishmania_susl/data/aethiopica_amber_fastq/fastq_files_batch2.csv
## adapt script towards *R1.fastq.gz and *R3.fastq.gz
# while IFS= read -r fastq_file_R1; do sbatch --export=fastq_file_R1=${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done < ~/scratch/leishmania_susl/data/aethiopica_amber_fastq/fastq_files_batch2.csv


## run for the SureSelect skinslits versus Biopsy samples
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/aethiopica_skinslit
# for fastq_file_R1 in *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

## run for the extra genomes that are included in the paper of Amber
## on aethiopica diversy (Ldon, Linf, Ltrop and Lmajor genomes)
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/amber_extragenomes_fastq/
# for fastq_file_R1 in *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done




## run for the sWGA samples of Allison on Lbraziliensis
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga_2023/
# for fastq_file_R1 in  *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done


## run for the artificial mixes of Lbraz SureSelect, to simulate how
## mixed infections would look like
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/artificial/fastq/
# for fastq_file_R1 in  *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done


## run for the samples of SomaliLeish --> those should be tropcia samples so 
## assume tropica as reference genome
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/aethiopica_somalileish
# for fastq_file_R1 in  *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

## run for all the L. tropica samples from Morocco, which is including both the 
## SureSelect data as well as WGS data
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/morocco_tropica_fastq/
# for fastq_file_R1 in *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

## do the same for the artificial mixes, to make sure that the somey differences 
## you see at chromosome 8 and 31 are not artefacts
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/artificial_mixes_tropica/
# for fastq_file_R1 in *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done


## run for the SureSelect skinslits batch 2 samples (january 2025)
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/aethiopica_skinslit2/
# for fastq_file_R1 in *_R1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done

## run for the Lainsoni SRA data, so that there is also a lainsoni reference genome
## available for SuSL/sWGA analysis of L. braziliensis. Lainson was not present in the 
## Viannia subdirectory from Fre and Senne (only Naiffi and Guyanensis), so should be
## added manually
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/fastq_lainsoni/
# for fastq_file_R1 in *_1.fastq.gz; do sbatch --export=fastq_file_R1=${PWD}/${fastq_file_R1} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.slurm; done