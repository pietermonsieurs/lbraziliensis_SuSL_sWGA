#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --mem=100G
#SBATCH --job-name=lbraz_coverage_subsampling_seqtk
#SBATCH --time=50:00:00
#SBATCH -A ap_itg_mpu


## load modules
module load seqtk


## define variables
output_dir=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/fastq/

# depths=(5000000 10000000 15000000 20000000 25000000 30000000 \
#          35000000 40000000 45000000 50000000)
depths=(20000000 25000000 30000000 \
         35000000 40000000 45000000 50000000)           
seeds=(10 20 30)


## check the project code of the fastq file and change the input fastq file based
## on that project
fastq_dir_104989=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/20220503/
fastq_dir_105328=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/SINGLE_SuSL_20230116/merged/
fastq_dir_105561=/user/antwerpen/205/vsc20587/aitg_data/jcdujardin/SINGLE_sWGA_20230516/merged/

## check the project code of the fastq file and change the input fastq file based
echo ${sample_code}
if [[ ${sample_code} == 104989* ]]; then
    fastq_dir=${fastq_dir_104989}
elif [[ ${sample_code} == 105328* ]]; then
    fastq_dir=${fastq_dir_105328}
elif [[ ${sample_code} == 105561* ]]; then
    fastq_dir=${fastq_dir_105561}
else
    echo "Project code not recognized. Exiting."
    exit 1
fi

## check if the fastq file exists
fastq_file_R1=${fastq_dir}/${sample_code}_R1.fastq.gz
fastq_file_R2=${fastq_dir}/${sample_code}_R2.fastq.gz

if [[ ! -f ${fastq_file_R1} || ! -f ${fastq_file_R2} ]]; then
    echo "Fastq files not found for sample ${sample_code}. Exiting."
    echo "Fastq file R1: ${fastq_file_R1}"
    echo "Fastq file R2: ${fastq_file_R2}"
    exit 1
fi

## calculate the total number of reads in the fastq file, to prevent that we 
## will be doing upsampling
total=$(( $(zcat "${fastq_file_R1}" | wc -l) / 4 ))
echo "Total number of reads in ${fastq_file_R1}: ${total}"

## run seqtk to subsample the fastq files for different sampling depths
for depth in "${depths[@]}"; do
    if [[ ${depth} -gt ${total} ]]; then
        echo "Requested depth ${depth} is greater than total reads ${total}. Skipping."
        continue
    fi
    for seed in "${seeds[@]}"; do
        output_file_R1=${output_dir}/${sample_code}_R1_subsampled_${depth}_${seed}.fastq.gz
        output_file_R2=${output_dir}/${sample_code}_R2_subsampled_${depth}_${seed}.fastq.gz
        
        echo "Subsampling ${fastq_file_R1} and ${fastq_file_R2} to depth ${depth} with seed ${seed}"
        
        seqtk sample -s${seed} ${fastq_file_R1} ${depth} | gzip > ${output_file_R1}
        seqtk sample -s${seed} ${fastq_file_R2} ${depth} | gzip > ${output_file_R2}
        
        echo "Subsampled files created: ${output_file_R1}, ${output_file_R2}"
    done
done

## write a for loop to loop over all project codes in a text file and submit the job for each project code
# project_codes_file=/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/subsampling/project_codes.txt
# while IFS= read -r project_code; do
#     sbatch --export=sample_code=${project_code} /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/lbraz_coverage_subsampling_seqtk.slurm
# done < ${project_codes_file}


