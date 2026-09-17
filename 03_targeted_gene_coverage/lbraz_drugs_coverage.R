library(ggplot2)
library(pheatmap)
library(openxlsx)
library(reshape2)

#### 1. input data ####

## read in all cov files
cov_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/drugs/'
cov_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/final/drugs_coverage'
cov_files <- list.files(path = cov_dir, pattern = "\\.cov$", full.names = TRUE)

## metadata 
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
meta_data = read.xlsx(meta_data_file, sheet = 'Lbraziliensis.direct_sequencing')
head(meta_data)



## get the drug gene dataframe
drug_resistance_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis_drugresistance.xlsx'
drug_data = read.xlsx(drug_resistance_file, sheet="summary")
drug_data$chrom = as.integer(drug_data$chrom)
head(drug_data)


#### 2. coverage data ####
min_coverage = 5
perc_covered_data <- data.frame(name = character(), gene = character(), protocol = character(), percentage = numeric(), stringsAsFactors = FALSE)

## do some initialisation
first_row = 1
rownames = c()
colnames = c()

for (cov_file in cov_files) {
  
  ## read in the coverage data
  cov_data = read.table(cov_file, header=FALSE)
  colnames(cov_data) = c('chrom', 'pos', 'cov')
  
  ## extract the sample name
  sample_full = tail(strsplit(cov_file, "/")[[1]], 1)
  sample <- strsplit(sample_full, "\\.")[[1]][1]
  name = meta_data[meta_data$ID_code == sample,]$name_unified
  type = meta_data[meta_data$ID_code == sample,]$Type
  if (type == 'sWGA') {
    type = paste0(type, '_', meta_data[meta_data$ID_code == sample,]$protocol)
  }
  
  print(name)
  rownames = c(rownames, name)
  
  row_to_add = c(name, gene, type)

  for (i in 1:nrow(drug_data)) {
    ## extract the information from the drug resistance file
    chrom_short = drug_data[i,]$chrom
    chrom = paste0('LbrM.', sprintf("%02d", chrom_short), '_v4_pilon')
    start = drug_data[i,]$start
    end = drug_data[i,]$end
    gene = drug_data[i,]$gene_short
    category = drug_data[i,]$category
    geneL = drug_data[i,]$end - drug_data[i,]$start + 1
    print(paste0(" --> ",gene))
    
    
    ## get number of positions that have a coverage highere than the 
    ## minimum coverage set above
    cov_data_gene = cov_data[cov_data$chrom == chrom & cov_data$pos >= start & cov_data$pos <= end,]
    pos_above_min = sum(cov_data_gene$cov > min_coverage)
    percentage = pos_above_min / geneL

    ## add row the overall data frame
    row_to_add = c(row_to_add, percentage)
    
    ## column names
    colnames = c(colnames, gene)
    
  }
  
  if (first_row == 1) {
    perc_covered_data = as.data.frame(t(as.data.frame(row_to_add)))
    colnames(perc_covered_data) = c('name', 'gene', 'protocol', colnames)
    first_row = 0
  }
  else{
    perc_covered_data = rbind(perc_covered_data, row_to_add)
  }
  
}

head(perc_covered_data)
dim(perc_covered_data)
rownames(perc_covered_data)

## keep the perc_covered_data as main matrix and do 
## subsequent filtering on copy plot_data. Remove the gene
## column, and replace the type and protocol name by changing
## the rownames. Also, convert all "strings" to numeric values
plot_data = perc_covered_data
plot_data = plot_data[order(plot_data$protocol, plot_data$name),]
plot_data = plot_data[, -2]
rownames(plot_data) = paste0(plot_data$name, '_', plot_data$protocol)
plot_data = plot_data[,-c(1,2)]
plot_data[] <- lapply(plot_data, as.numeric)
head(plot_data)

## remove the mixes 
plot_data = plot_data[-grep("Mix", rownames(plot_data)),]
plot_data
# plot_data = plot_data[-grep("LbrM.", rownames(plot_data)),]

## add annotation data to visualize the genes based 
annotation_data = as.data.frame(drug_data$category)
colnames(annotation_data) = c('Category')
rownames(annotation_data) = drug_data$gene_short


p = pheatmap(plot_data,
         cluster_cols = FALSE,
         cluster_rows = FALSE,
         annotation_col = annotation_data,
         fontsize_row = 10)
p
is.numeric(plot_data)

heatmap_file = paste0(cov_dir, "/heatmap_coverage_drug_genes.pdf")
ggsave(p, file = heatmap_file, width = 16, height = 8, dpi=300)

