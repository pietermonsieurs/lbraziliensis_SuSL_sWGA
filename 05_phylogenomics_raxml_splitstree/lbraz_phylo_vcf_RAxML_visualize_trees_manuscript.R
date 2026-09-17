library(ggtree)
library(openxlsx)
library(ggplot2)
library(treeio)
library(gridExtra)


#### figure S5 ####

enrich_types = c('SuSL', 'sWGA_baits', 'sWGA_digest')
fractions = c('0.5', '0.8', '0.9', '0.95')


#### figure S6 ####

## code is extracted from lbraz_phylo_vcf-RAxML_visualize_trees.R

## setting the tree directory
tree_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/trees_phylo/'

## metadata 
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
meta_data = read.xlsx(meta_data_file, sheet = 'metadata_phylo')
head(meta_data)


## create a function to make a simple tree
simpleTree <- function(tree, text_size=1.5) {
  ## quick and dirty preview to check whether we are working
  ## with the correct file
  
  p = ggtree(tree) + 
    geom_tiplab(size=text_size) + 
    theme_tree2() 
  p
  
}


enrich_type = 'SuSL'
fraction = '0.95'

## read in tree and rename tip lables
tree_name = paste0('phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.snps.T3.raxml.bestTree')
tree_file = paste0(tree_dir, tree_name)
tree = read.newick(tree_file)
tree$tip.label[grep("SuSL", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("SuSL", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))
tree$tip.label[grep("sWGA", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("sWGA", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))

## figure S6 -- Liasoni to be added!!
simpleTree(tree)


#### figure S7 ####

## continue on code above, and remove the liansoni strain + naiffi + all other 
## non-lbraz strains

## remove the outliers from naiffi + putative lainsoni
tree = drop.tip(tree, tip = c("Lnaiffi_ERR205764", "LFA-CU-104", "SRR1657912"))
simpleTree(tree)

## remove other species
tree = drop.tip(tree, tip = c("Lguyanensis_SRR1662195", "Lshawi_SRR1657909", "Lpanamensis_SRR1662198"))
simpleTree(tree)

## remove samples with questionable quality:  -- Figure S7
tree = drop.tip(tree, tip = c("PER182A1", "Lb7616"))
simpleTree(tree)


## optional, but not included: also remove samples originating from lineage 2 + in between sample 024
tree = drop.tip(tree, tip = c("LFA-CU-024"))
tree = drop.tip(tree, tip = c("LFA-CU-009","PER163A1","CUM555A1","CUM663A1"))
simpleTree(tree, text_size = 2.3)




#### figure S8 ####

enrich_type = 'sWGA_baits'
fraction = '0.95'

## read in tree and rename tip lables
tree_name = paste0('phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.snps.T3.raxml.bestTree')
tree_file = paste0(tree_dir, tree_name)
tree = read.newick(tree_file)
tree$tip.label[grep("SuSL", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("SuSL", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))
tree$tip.label[grep("sWGA", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("sWGA", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))
simpleTree(tree)

## remove the outliers from naiffi + putative lainsoni & remove other species
tree = drop.tip(tree, tip = c("Lnaiffi_ERR205764", "LFA-CU-104", "SRR1657912"))
tree = drop.tip(tree, tip = c("Lguyanensis_SRR1662195", "Lshawi_SRR1657909", "Lpanamensis_SRR1662198"))
tree = drop.tip(tree, tip = c("PER182A1", "Lb7616"))
tree = drop.tip(tree, tip = c("LFA-CU-009","PER163A1","CUM555A1","CUM663A1"))
simpleTree(tree, text_size = 2.3)











