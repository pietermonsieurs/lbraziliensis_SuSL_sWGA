#!/usr/bin/env python3

import glob

fastq_screen_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_fastq_screen/broad_range/'
output_file = f"{fastq_screen_dir}/fastqscreen_parsed.csv"
out_fh = open(output_file, 'w')

fastq_screen_files = glob.glob(f"{fastq_screen_dir}*.txt")
for fastq_screen_file in fastq_screen_files:
    print(fastq_screen_file)

    ## extrat the sample name
    sample = fastq_screen_file.split("/")[-1]
    sample = sample.replace('.txt', '')

    fastq_fh = open(fastq_screen_file, 'r')

    ## omit the first two lines (comment + header)
    fastq_fh.readline()
    fastq_fh.readline()

    ## loop over the different species
    for line in fastq_fh:
        line = line.rstrip()

        if line.startswith("%") or line == "": 
            continue

        print(f"--> {line}")
        data = line.split("\t")
        
        
        ## extract reads uniqely mapping to genome (might be multi
        ## mappers within the same genome)
        species = data[0]
        percent_unique = data[5]
        percent_multi = data[7]
        percent_species = float(data[5]) + float(data[7])
        line_out = f"{species},{percent_species},{sample}"
        print(line_out)
        out_fh.write(f"{line_out}\n")