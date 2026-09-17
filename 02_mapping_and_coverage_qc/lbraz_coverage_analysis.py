#!/usr/bin/env python3


import sys
import glob

my_debug = 0
reads_per_sample_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/coverage/reads_per_sample.csv'
coverage_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/'

## read cov_file from the input
if len(sys.argv) >= 2:
    cov_file = sys.argv[1]  # Accessing the parameter
    print(f"running for {cov_file}")
else:
    print("Please provide a samtools depth output file.")
    sys.exit()

## extract the number of reads per sample, and conver to 
## number of million reads as you want to express as number
## per million reads
million_reads = {}
reads_per_sample_fh = open(reads_per_sample_file, 'r')
for line in reads_per_sample_fh:
    line = line.rstrip()
    data = line.split(",")
    million_reads[data[0]] = float(data[1])/1000000
my_debug and print(million_reads)

## test files for cov_file
# cov_files = glob.glob(f"{coverage_dir}/*.depth")
# cov_file = cov_files[0]


minimum_coverage = 5

## extract the sample name from the coverage file
my_debug and print(f"{cov_file}")
sample = cov_file.split("/")[-1]
sample = sample.replace(".mapq30.removedups.proper_paired.depth", "")

## create an output file
output_file = f"{cov_file}.parsed.csv"
out_fh = open(output_file, 'w')



for millions in range(1,100):

    ## initialize the counter to count the number of positions that 
    ## are higher than the minimal set coverage. Also set the 
    ## genome size to 0
    count = 0
    genome_size = 0
    
    ## open the coverage file - one time per sequencing depth 
    ## parameters
    cov_fh = open(cov_file)

    for line in cov_fh: 

        line = line.rstrip()
        genome_size = genome_size + 1

        ## calculation of the sequencing depth: divide the coverage by 
        ## the total number of sequencing reads in the dataset 
        ## (million_reads[sample]) and multiply with the applied sequencing
        ## depth. Check if depth is higher than the minimum coverage.
        depth = int(line.split("\t")[2])*millions/million_reads[sample]
        if depth >= minimum_coverage:
            count = count + 1

    fraction_covered = count / genome_size
    line_out = f"{sample},{millions},{count},{fraction_covered}\n"
    print(line_out)
    out_fh.write(line_out)

    cov_fh.close()

out_fh.close()

