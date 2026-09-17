#!/usr/bin/env python3

print("importing libraries")
import sys
import re
from Bio import SeqIO
# import pandas as pd
# import statistics  
# import ntpath

print("reading parameters...")
org = sys.argv[1]
primer_seq = sys.argv[2]
primer_id = sys.argv[3]
author = sys.argv[4]

my_debug = 1
# primer_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/primer_eval/'
# org = 'Ldon'
# org = 'Human'

if org == 'Ldon':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/Leishmania_donovani_16Nov2015beta.fa'
elif org == 'Human':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa'
elif org == 'Lamaz':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-59_LamazonensisMHOMBR71973M2269_Genome.fasta'
elif org == 'Linf':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-46_LinfantumJPCM5_Genome.fasta'
elif org == 'Lbraz':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-57_LbraziliensisMHOMBR75M2904_2019_Genome.fasta'
elif org == 'Lmaj':
    fasta_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/refgenomes/TriTrypDB-59_LmajorFriedlin2021_Genome.fasta'
else:  
    sys.exit(f"ref genome not found for species {org}")


## create the output file based on the directory and the primer file + organism
output_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/primer_eval_pilling/'
output_file = f"{output_dir}/{author}.{org}.primer_{primer_id}.primer_counts.csv"

print(output_file)


out_fh = open(output_file, 'w')
count_primer = 0

my_debug and print(f"primer - {primer_id}")
for chrom_record in SeqIO.parse(fasta_file, "fasta"):
    my_debug and print(f"\tchrom [{chrom_record.id}]")
    count_primer = count_primer + str(chrom_record.seq).count(str(primer_seq))
    
    
print(f"primer [{primer_id}] counted [{count_primer}] times -- per Mbp {int(count_primer/33)}")
line_out = f"{primer_id},{org},{author},{count_primer}\n"
out_fh.write(line_out)
out_fh.close()



