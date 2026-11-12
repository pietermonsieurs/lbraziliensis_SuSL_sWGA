#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=10:00:00
#SBATCH -A ap_itg_mpu

## load modules
conda deactivate
module purge
module load calcua/2024a
module load BWA
module load SAMtools
module load Java


## define variables
ref_genome=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-59_LbraziliensisMHOMBR75M2904_2019_Genome.fasta
fastq_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/fastq/
output_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/bwa/
# depths=(5000000 10000000 15000000 20000000 25000000 30000000 \
#          35000000 40000000 45000000 50000000)  
# seeds=(10 20 30)
seed_bwa=50
threads=28
threads_bwa=24
threads_samtools=4

## PICARD settings
PICARD_JAR=/data/antwerpen/205/vsc20587/software/picard/picard.jar
PICARD_BIN="java -jar ${PICARD_JAR}"
mapq_cutoff=30

## mkdir output directory
mkdir -p ${output_dir}

## create fastq_files and output files

echo "Processing depth: ${depth}, seed: ${seed}"

fastq_file_R1=${fastq_dir}/${sample_code}_R1_subsampled_${depth}_${seed}.fastq.gz
fastq_file_R2=${fastq_dir}/${sample_code}_R2_subsampled_${depth}_${seed}.fastq.gz
bam_file=${output_dir}/${sample_code}_subsampled_${depth}_${seed}.bam

bwa mem \
    -R "@RG\tID:${sample_code}\tSM:${sample_code}\tPL:ILLUMINA" \
    -k $seed_bwa \
    -t $threads_bwa \
    ${ref_genome} \
    ${fastq_file_R1} \
    ${fastq_file_R2} | \
samtools sort -@$threads_samtools -o ${bam_file}
samtools index ${bam_file}

### selection on mapping quality ###
samtools view -@ $threads -bq $mapq_cutoff ${bam_file} > ${bam_file%.bam}.mapq${mapq_cutoff}.bam
samtools index ${bam_file%.bam}.mapq${mapq_cutoff}.bam
# samtools flagstat ${bam_file%.bam}.mapq${mapq_cutoff}.bam > ${bam_file%.bam}.mapq${mapq_cutoff}.flagstat

### remove duplicate reads ### 
$PICARD_BIN MarkDuplicates REMOVE_DUPLICATES=true I=${bam_file%.bam}.mapq${mapq_cutoff}.bam O=${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam M=${bam_file%.bam}.mapq${mapq_cutoff}.markdups_metrics.txt
samtools index ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam
# samtools flagstat ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam > ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.flagstat


### select only proper paired reads ###
samtools view -@$threads -bf 0x2 ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam > ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.proper_paired.bam
samtools index ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.proper_paired.bam
samtools flagstat ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.proper_paired.bam > ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.proper_paired.flagstat

## do clean up and removate all intermediate files - only keep the final bam file with proper paired reads
## also remove the index files and flagstat files for the intermediate files
rm ${bam_file}
rm ${bam_file}.bai
rm ${bam_file%.bam}.mapq${mapq_cutoff}.bam
rm ${bam_file%.bam}.mapq${mapq_cutoff}.bam.bai
rm ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam
rm ${bam_file%.bam}.mapq${mapq_cutoff}.removedups.bam.bai
rm ${bam_file%.bam}.mapq${mapq_cutoff}.markdups_metrics.txt
        


## run for all project codes
# project_codes_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/project_codes.txt
# while IFS= read -r project_code; do
#     sbatch --export=sample_code=${project_code} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_subsampling_bwa.slurm
# done < ${project_codes_file}

## update: run for all project codes, but also put the sample depth and seed in 
## the for loop for the sbatch command, so that each job will run for a specific depth and seed combination
# depths=(5000000 10000000 15000000 20000000 25000000 30000000 \
#          35000000 40000000 45000000 50000000)  
# seeds=(10 20 30)
# project_codes_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/project_codes.txt
# while IFS= read -r project_code; do
#     for depth in ${depths[@]}; do
#         for seed in ${seeds[@]}; do
#             sbatch --export=sample_code=${project_code},depth=${depth},seed=${seed} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_subsampling_bwa.slurm
#         done
#     done
# done < ${project_codes_file}




