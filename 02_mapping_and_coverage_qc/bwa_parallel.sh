#!/bin/bash -l

#PBS -l walltime=00:59:00
#PBS -L tasks=1:lprocs=28

## load modules
module load BWA/0.7.17-GCCcore-8.3.0
module load SAMtools/1.9-intel-2019b
module load Java


## define variables
export THREADS=28
export SEED=50

## DATA_DIR
# export DATA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/
export DATA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210714/

## BWA_DIR
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/subsample_permix/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210622/subsample_overall/
# export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210714/
export BWA_DIR=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/bwa_20210714/subsample_permix/

export REF_GENOME=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/Leishmania_donovani_16Nov2015beta.fa
export PICARD_JAR=/data/antwerpen/205/vsc20587/software/picard/picard.jar
export PICARD_BIN="java -jar ${PICARD_JAR}"
export mapq_cutoff=30


### index reference genomes
## indexing already performed in previous analysis
# bwa index $REF_GENOME

## create the necessary filenames based on te input information
# fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/HCCHFDSX2_104509-001-003_GCCAAGAC_L001_R1.fastq.gz
# fastq_file_R1=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/HCCHFDSX2_104509-001-001_AACGTGAT_L002_R1.fastq.gz

## depending on which sequencing file, you have to choose either R2 or R3
# fastq_file_R2=${fastq_file_R1/_R1.fastq.gz/_R2.fastq.gz}
fastq_file_R2=${fastq_file_R1/_R1.fastq.gz/_R3.fastq.gz}
file_prefix=${fastq_file_R1%_L00*_R1.fastq.gz}
file_prefix=${file_prefix##*/}
bam_file_prefix=${BWA_DIR}/${file_prefix}

### run BWA with increased seed 
# bwa mem -k $SEED -t $THREADS $REF_GENOME $fastq_file_R1 $fastq_file_R2 | samtools sort -@$THREADS -o ${bam_file_prefix}.bam
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


#### run using different qsub commands ####

# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210622/
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20210714/
# for fastq_file_R1 in  *R1.fastq.gz; do qsub -v fastq_file_R1=$PWD/$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/bwa_parallel.sh; done
