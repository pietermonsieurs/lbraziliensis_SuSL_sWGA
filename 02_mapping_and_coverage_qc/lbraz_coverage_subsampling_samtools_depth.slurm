#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=2
#SBATCH --time=10:00:00
#SBATCH -A ap_itg_mpu

## load modules
module load SAMtools

## run for a single project code, depth, and seed combination
bwa_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/bwa/
depth_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/depth/
bam_file=${bwa_dir}/${sample_code}_subsampled_${depth}_${seed}.mapq30.removedups.proper_paired.bam
output_file=${depth_dir}/${sample_code}_subsampled_${depth}_${seed}.mapq30.removedups.proper_paired.depth.txt
count_file=${depth_dir}/${sample_code}_subsampled_${depth}_${seed}.mapq30.removedups.proper_paired.depth_count.txt

## create the output directory if it does not exist
mkdir -p ${depth_dir}

## run samtools depth for all positions in the genome, and output to a file
samtools depth -a ${bam_file} > $output_file

## count the number of positions with depth greater than 5, and output to a file
count_above_treshold=$(awk '{if($3>4) count++} END {print count}' ${output_file})

## output the count to a file with also name of the sample_code, seed, and depth
echo -e "${sample_code}\t${depth}\t${seed}\t${count_above_treshold}" > ${count_file}


## run for all project codes, but also put the sample depth and seed in 
## the for loop for the sbatch command, so that each job will run for a specific depth and seed combination
# depths=(5000000 10000000 15000000 20000000 25000000 30000000 \
#          35000000 40000000 45000000 50000000)  
# seeds=(10 20 30)
# project_codes_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/project_codes.txt
# rm /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/bwa/lbraz_coverage_subsampling_samtools_depth.tsv
# while IFS= read -r project_code; do
#     for depth in ${depths[@]}; do
#         for seed in ${seeds[@]}; do
#             sbatch --export=sample_code=${project_code},depth=${depth},seed=${seed} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_subsampling_samtools_depth.slurm
#         done
#     done
# done < ${project_codes_file}