#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=28
#SBATCH --time=10:00:00

## load python module, which will at this moment (27/09/2022) enable
## Python 3.8.3 + load different pre-installed libraries + specify 
## Python paht and add swga and jellyfish to PATH
module load Python
export PYTHONPATH="/user/antwerpen/205/vsc20587/data/software/python_lib/lib/python3.8/site-packages/:${PYTHONPATH}"
export PATH="/user/antwerpen/205/vsc20587/data/software/python_lib/bin/:/user/antwerpen/205/vsc20587/data/software/jellyfish-2.3.0/:${PATH}"
threads=28


## specify source params.json file
# json_template=/user/antwerpen/205/vsc20587/data/software/swga2/testing3/params.json
# json_template=/user/antwerpen/205/vsc20587/data/software/swga2/testing3/params.increasedTm.json
# json_template=/user/antwerpen/205/vsc20587/data/software/swga2/testing3/params.increasedTm_and_reducedBgFreq.json
json_template=/user/antwerpen/205/vsc20587/data/software/swga2/testing4/params.increasedTm_and_reducedBgFreq2.json

## create parameter names using batch ID
src_dir=/user/antwerpen/205/vsc20587/data/software/swga2/
# batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_${batch}/
# batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_increasedTm_${batch}/
# batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_increasedTm_reducedBgFreq_${batch}/
batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_increasedTm_reducedBgFreq2_${batch}/
meta_data_dir=${batch_dir}/metadata/

# json_file=${batch_dir}/params.json
# json_file=${batch_dir}/params.increasedTm.json
# json_file=${batch_dir}/params.increasedTm_and_reducedBgFreq.json
json_file=${batch_dir}/params.increasedTm_and_reducedBgFreq2.json

## create the different directories
mkdir ${batch_dir}
mkdir ${meta_data_dir}

## copy the json template to the correct directory
cp $json_template $json_file


## run SWGA2 in four steps
soapswga step1 -j ${json_file} -z ${meta_data_dir}
soapswga step2 -c ${threads} -j ${json_file} -z ${meta_data_dir}
soapswga step3 -c ${threads} -j ${json_file} -z ${meta_data_dir}
soapswga step4 -c ${threads} -j ${json_file} -z ${meta_data_dir}

## run with batch ID as export variable
# for batch_id in {1..10}; 
# do 
#     echo $batch_id
#     batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_${batch_id}/
#     sbatch --export=batch=$batch_id --output=${batch_dir}/swga2.batch_${batch_id}.out /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga2_run_parallel.sh
# done

# for batch_id in {11..25}; 
# do 
#     echo $batch_id
#     batch_dir=/user/antwerpen/205/vsc20587/data/software/swga2/batch_${batch_id}/
#     sbatch --export=batch=$batch_id /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga2_run_parallel.sh
# done

## with increased temperature
# for batch_id in {1..25}; 
# do 
#     echo $batch_id
#     sbatch --export=batch=$batch_id /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga2_run_parallel.sh
# done

## with increased temperature and reduced bg freq
# for batch_id in {1..50}; 
# do 
#     echo $batch_id
#     sbatch --export=batch=$batch_id /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga2_run_parallel.sh
# done

## with increased temperature and (even further) reduced bg freq
# for batch_id in {1..1}; 
# do 
#     echo $batch_id
#     sbatch --export=batch=$batch_id /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga2_run_parallel.sh
# done

