#!/usr/bin/env python3

## module load Python/3

import pandas as pd

## set enrichtype
# enrich_type_short = 'SuSL'
enrich_type_short = 'sWGA'

enrich_type_protocol= "baits"
# enrich_type_protocol = "digest"

if enrich_type_short == 'SuSL':
    enrich_type = f'phylo.{enrich_type_short}'
elif enrich_type_short == 'sWGA':
    enrich_type = f'phylo.{enrich_type_short}_{enrich_type_protocol}'

## input data 
vcf_dir = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/results/lbraz_susl_swga/phylo/'
missingness_file = f'{vcf_dir}/{enrich_type}.plink2.smiss'
meta_data_file = '/user/antwerpen/205/vsc20587/scratch/leishmania_susl/data/Lbraziliensis.direct_sequencing.csv'
vcf_file_prefix = 'lbraz_susl_swga.filtered_stringent.renamed'


## parameter settings   
# fractions = [0.50, 0.80, 0.90, 0.95]
fractions = [0.50, 0.95]

## read in the source data as a pandas data frame
miss_df = pd.read_csv(missingness_file, sep="\t")
meta_df = pd.read_csv(meta_data_file)

print(miss_df.head)
print(meta_df.head)

print(meta_df.columns)


print(f"=> creating input files for {enrich_type}")

if enrich_type_short == "SuSL":
    #print(f"SuSL - {enrich")
    meta_subset_df = meta_df[(meta_df['Type'] == enrich_type_short) & (meta_df['Type2'] == 'Clinical Sample')]
elif enrich_type_short == 'sWGA':
    meta_subset_df = meta_df[(meta_df['Type'] == enrich_type_short) & (meta_df['Type2'] == 'Clinical Sample') & (meta_df['protocol'] == enrich_type_protocol)]

print(meta_subset_df.shape)
print(meta_subset_df['name_unified'])


for fraction in fractions:

    print(f"  ---> creating input file for max fraction {fraction} missing genotype")
    
    ## create the output file name containing the samples that are retained 
    ## for a certain enrichment technology & maximum fraction of missing
    ## genotypes
    sample_file = f"{vcf_dir}/subset_remove.{enrich_type}.fraction{fraction}.txt"
    rename_file = f"{vcf_dir}/subset.{enrich_type}.fraction{fraction}.rename.txt"
    
    # sample_file_no_outlier = f"{vcf_dir}/subset.{enrich_type}.fraction{fraction}.without_104.txt"
    # rename_file_no_outlier = f"{vcf_dir}/subset.{enrich_type}.fraction{fraction}.rename.without_104.txt"
    
    
    sample_fh = open(sample_file, 'w')
    rename_fh = open(rename_file, 'w')
    # sample_noout_fh = open(sample_file_no_outlier, 'w')
    # rename_noout_fh = open(rename_file_no_outlier, 'w')

    for index, row in meta_subset_df.iterrows():
        sample_id = row['ID_code']
        missing_fraction = miss_df.loc[miss_df['#IID'] == sample_id, 'F_MISS'].values

        ## if the fraction is higher than the max allowed fraction
        ## of missing genotype, write to file containing the samples that
        ## need to be removed. If not, write it to the text file containing
        ## the sample that should be renamed. 
        print(f"{sample_id} --> missing fraction: {missing_fraction}")
               
        if missing_fraction > fraction:
            sample_fh.write(f"{sample_id}\n")
        else:
            sample_name = f"{row['name_unified']}_{row['Type']}_{row['protocol']}"
            rename_fh.write(f"{sample_id}\t{sample_name}\n")

            # if row['name_unified'] != "LFA-CU-104":
            #     sample_noout_fh.write(f"{sample_id}\n")
            #     rename_noout_fh.write(f"{sample_id}\t{sample_name}\n")

    


    sample_fh.close()
    rename_fh.close()
    # sample_noout_fh.close()
    # rename_noout_fh.close()
    


    


