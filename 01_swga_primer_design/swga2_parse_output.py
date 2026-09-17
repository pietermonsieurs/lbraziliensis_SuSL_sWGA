#!/usr/bin/env python3

import glob

results_dir = '/user/antwerpen/205/vsc20587/data/software/swga2/'

# start_index = 361585
# end_index = 361609

start_index = 365444
end_index = 365493



# for out_file in glob.glob(f"{results_dir}/slurm-35*.out"):
for file_index in range(start_index, end_index+1):
    # print(file_index)
    out_file = f"{results_dir}/slurm-{file_index}.out"
    out_fh = open(out_file, 'r')
    last_10_lines = out_fh.readlines()[-10:]
    # print(last_10_lines)
    for line in last_10_lines:
        line = line.rstrip()
        primers, score = line.split("], ")
        primers = primers.replace("[", "")
        nr_of_primers = len(primers.split(","))
        # print(f"{primers} --> {score} :: {nr_of_primers}")
        print(f"{primers}\t{score}\t{nr_of_primers}")
