#!/bin/bash -l

#SBATCH --ntasks=1 --cpus-per-task=2
#SBATCH --mem-per-cpu=8Gb
#SBATCH --time=5:00:00

module load BioTools-Python
module load atools

# source <(aenv --data  /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters.csv)
# source <(aenv --data  /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_v2.csv)
# source <(aenv --data  /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_v3.csv)
# source <(aenv --data  /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_v4.csv)
# source <(aenv --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_perprimer.csv)
# source <(aenv --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_perprimer_swga2.csv)
source <(aenv --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increasedTm_decreasedBgFreq.output_50batches.parameters.csv)

echo $org
echo $primer
echo $primer_id
echo $author


python3 /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga_checkprimers_crossspecies_perprimer.py $org $primer $primer_id $author

## run with atools
## run everything with worker module. input parameter file is made below and
## contains directly the primer sequence instead of a fasta file. Primer
## sequencies copies to excel file on laptop and edited there

# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga
# cd allison
# sed -n 'n;p' primers_unique.fa ## print only even lines = primer sequences
## do this for every directory and past into excel to edit the parameters csv file
## file:  /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_perprimer.csv
# module load atools
# sbatch --array $(arange --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_perprimer.csv) /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga_checkprimers_crossspecies_perprimer.sh

## run for final primer sets using sWGA2 (so not on all input primers, only the final primers selected)
## input parameter file is created using [./swga_checkprimers_primers_second_version_final.py] for
## default swga + swga with increased Tm, and both parameter files are concatenated + header added
# module load atools
# sbatch --array $(arange --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/swga/primer_eval_parameters_perprimer_swga2.csv) /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga_checkprimers_crossspecies_perprimer.sh
# cd /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/primer_eval_pilling/
# cat *.L*primer_counts.csv > primer_counts.updated.csv
# cat *.Human.*.primer_counts.csv > Human.primer_counts.updated.csv


## same but now for increased melting temperature and decreased Background frequency 
## in the host / background genome
# sbatch --array $(arange --data /user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increasedTm_decreasedBgFreq.output_50batches.parameters.csv) /user/antwerpen/205/vsc20587/scratch/leishmania_susl/bin/swga_checkprimers_crossspecies_perprimer.sh