#!/usr/bin/env python3

import glob
import pandas as pd
import sys
from itertools import product
import os

## get input from sbatch command
# cov_file = os.environ.get('cov_file')
cov_file = sys.argv[1] 
print(f"cov_file {cov_file}")

## input data 
cov_directory = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/'
bed_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019.genes.bed'

## select all cov files and select the cutoff parameters
## needed to analyse the coverage
# cov_files = glob.glob(f"{cov_directory}/*paired.cov")
cov_file_out = cov_file.replace(".cov", ".cov.summary")
out_fh = open(cov_file_out, 'w')

cov_cutoffs = [5,10,20]
perc_cutoffs = [50,80,75,90,100]
spacer = "_"

header_data = [str(cov) + spacer + str(perc) for cov, perc in product(cov_cutoffs, perc_cutoffs)]
header_line = ",".join(header_data)
header = f"sample,{header_line}"
print(header)

# for cov_file in cov_files:
    
## read in the coverage data
print(cov_file)
cov_data = pd.read_csv(cov_file, sep='\t')
column_names = ['chrom', 'pos', 'depth']
cov_data.columns = column_names
cov_data['pos'] = pd.to_numeric(cov_data['pos'], errors='coerce')
print(cov_data.head)
cov_data = cov_data[cov_data['depth'] > 0]


## create the first part of the ouput line
line_out = cov_file

## create an empty dictionnary to store the counts
## for the different settings
counts = {param: 0 for param in header_data}

count = 0
bed_fh = open(bed_file, 'r')
for line in bed_fh:
    ## open the bed file and loop over the bed-file
    line = line.rstrip()

    ## extract the gene information
    chrom, start, end = line.split("\t")
    end = int(end)
    start = int(start)
    gene_L = end - start + 1
    print(f"chrom {chrom}: start {start} - end {end}")

    count = count + 1
    
    ## subset the cov_data object to only cover the gene of interest
    cov_sub = cov_data[(cov_data['chrom'] == chrom) & (cov_data['pos'] >= start) & (cov_data['pos'] <= end)]


    for cov_cutoff in cov_cutoffs:
        for perc_cutoff in perc_cutoffs:
            count_high_depth = len(cov_sub[cov_sub['depth'] >= cov_cutoff])
            percentage = count_high_depth/gene_L
            print(percentage)
            if percentage >= (perc_cutoff/100):
                param_setting = f"{cov_cutoff}_{perc_cutoff}"
                counts[param_setting] = counts[param_setting] + 1
                print(f"param setting [{param_setting}] -- percentage {percentage} is higher than {perc_cutoff/100} --> {counts[param_setting]}")

    # if count > 1: 
    #     break

counts_data = ",".join(map(str,counts.values()))
line_out = f"{line_out},{counts_data}"

print(line_out)
out_fh.write(line_out)
out_fh.close()


     

