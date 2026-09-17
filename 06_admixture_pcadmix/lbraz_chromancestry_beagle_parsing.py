#!/usr/bin/env python3

## chromosome file
chromosome_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/chroms.csv'
chrom_fh = open(chromosome_file, 'r')

for chrom in chrom_fh:
    chrom = chrom.rstrip()

    ## file anmes
    windows_file = f'/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/per_chrom/pcadmix.{chrom}.markers.txt'
    windows_file_out = f'/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/per_chrom/pcadmix.{chrom}.markers_table.csv'


    ## extract all windows from the windows file
    windows_fh = open(windows_file, 'r')
    out_fh = open(windows_file_out, 'w')

    for line in windows_fh:
        line = line.rstrip()
        data = line.split()
        
        ## extract the window, and the first and last position in the
        ## window file
        window = data[0]
        first = data[1]
        last = data[len(data)-1]

        window_index = 1 + int(window.replace("Window", ""))
        print(f"[{window_index}] {window}:{first}-{last}")
        start = first.replace(f"{chrom}:", "")
        end = last.replace(f"{chrom}:", "")

        line_out = f"{window_index},{window},{chrom},{start},{end}\n"
        print(line_out)        

        out_fh.write(line_out)
