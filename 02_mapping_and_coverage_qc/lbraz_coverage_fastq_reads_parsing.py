#!/usr/bin/env python3

import glob

out_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/coverage/'
slurm_files = glob.glob(f"{out_dir}/slurm-1312035*")

for slurm_file in slurm_files: 
    # print(f"{slurm_file}")
    slurm_fh = open(slurm_file)
    
    ## skip the first line and read true output
    slurm_fh.readline()
    outline = slurm_fh.readline()
    outline = outline.rstrip()
    data = outline.split(",")
    
    ## extract the sample name
    sample = data[0].split("/")[-1]
    sample = sample.replace("_R1.fastq.gz", "")

    ## calculate the number of reads
    nr_of_reads = int(data[1])/4
    print(f"{sample},{nr_of_reads}")


