#!/usr/bin/bash

#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=03:30:00

module load BioTools

## specify the output file
output_file=coverage_stats.csv

## find the number of lines in the fastq file, and divide by 
## 4 to have the number of reads
echo "fastq_file $fastq_file_R1"
line_count=$(zcat $fastq_file_R1 | wc -l)
number_of_reads=$((line_count / 4))

## extract the sample ID and create the bam_file
bwa_dir=/scratch/antwerpen/grp/aitg/jcdujardin/lbraz_susl_swga/
sample=$(basename ${fastq_file_R1})
sample=${sample/_R1.fastq.gz/}
bam_file=${bwa_dir}/${sample}.mapq30.removedups.proper_paired.bam
echo ${bam_file}
reads_mapped=$(samtools view ${bam_file} | wc -l)

## check the coverage higher than 5x
cov_file=${bwa_dir}/${sample}.mapq30.removedups.proper_paired.cov
count_pos_cov=$(awk -F'\t' '$3 > 4 {count++} END {print count}' ${cov_file})

## print the output
echo "${fastq_file_R1},${sample},${number_of_reads},${reads_mapped},${count_pos_cov}" >> ${output_file}



## calculate the raw input for the different fastq files, starting
## form the overview file containing the metadata
# fastq_R1_files=$(awk -F',' 'NR > 1 {print $16}' Lbraziliensis.direct_sequencing.csv)
# for fastq_file_R1 in ${fastq_R1_files[@]}; do sbatch --export=fastq_file_R1=$fastq_file_R1 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverages_stats.slurm; done