#!/usr/bin/env python3

# primer_input = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.output_50batches.csv'
# primer_output = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.output_50batches.parameters.csv'
# author = 'sWGA2_sets'

# primer_input = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increased_Tm.output_25batches.csv'
# primer_output = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increased_Tm.output_25batches.parameters.csv'
# author = 'sWGA2_Tm_sets'

primer_input = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increasedTm_decreasedBgFreq.output_50batches.csv'
primer_output = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/swga2/swga2.increasedTm_decreasedBgFreq.output_50batches.parameters.csv'
author = 'sWGA2_Tm_BgFreq_sets'

prim_in = open(primer_input, 'r')
prim_out = open(primer_output, 'w')

orgs = ['Human', 'Ldon', 'Lbraz', 'Lmaj', 'Linf', 'Lamaz']

prim_in.readline()

primers_seen = []


primer_id = 0
for primer_line in prim_in:
    primer_line = primer_line.rstrip()
    primers_field = primer_line.split("\t")[0]
    primers = primers_field.split(",")

    for primer in primers: 
        primer = primer.replace(" ", "")
        if primer in primers_seen:
            continue
        else:
            primers_seen.append(primer)
            primer_id = primer_id + 1

        for org in orgs: 
            line_out = f"{org},{primer},{author},{primer_id}\n"
            prim_out.write(line_out)



prim_in.close()
prim_out.close()