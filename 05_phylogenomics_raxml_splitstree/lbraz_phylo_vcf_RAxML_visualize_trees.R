library(ggtree)
library(openxlsx)
library(ggplot2)
library(treeio)
library(gridExtra)


#### 0. input data ####

## setting the tree directory. These three are created using a for loop over different
## enrichment methods and missingness factor. Created using: lbraz_phylo_vcf_RAxML.sh
## those trees are also used to create the trees in figure S5!
tree_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/trees_phylo/'


## metadata 
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
meta_data = read.xlsx(meta_data_file, sheet = 'metadata_phylo')
head(meta_data)

enrich_types = c('SuSL', 'sWGA_baits', 'sWGA_digest')
fractions = c('0.5', '0.8', '0.9', '0.95')

simpleTree <- function(tree, text_size=1.5) {
  ## quick and dirty preview to check whether we are working
  ## with the correct file
  
  p = ggtree(tree) + 
    geom_tiplab(size=text_size) + 
    theme_tree2() 
  p
  
}

complexTree <- function(tree, highlight) {
  p = ggtree(tree) +  
    theme_tree2() + 
    geom_tiplab(aes(label=label), size=2, color='black') + 
    geom_tippoint(mapping = aes_string(color=highlight, label='node'), size=1)
    # geom_text2(aes(label=label, subset = !is.na(as.numeric(label))& as.numeric(label) < 101 & as.numeric(label)  > 30), size=3, color="blue", nudge_x = -0.01, nudge_y=0.2) +
    # xlim(50,51)
    # xlim(-.1,1.2)
  p  
  return(p)
  
}




for (enrich_type in enrich_types) {
  for (fraction in fractions) {

    ## dummy data to omit the for loop
    # enrich_type = 'SuSL'
    # enrich_type = 'sWGA_baits'
    # enrich_type = 'sWGA_digest'
    # fraction = '0.95'
    
    ## read in tree
    tree_name = paste0('phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.snps.T3.raxml.bestTree')
    tree_file = paste0(tree_dir, tree_name)
    tree = read.newick(tree_file)
    tree$tip.label[grep("SuSL", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("SuSL", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))
    tree$tip.label[grep("sWGA", tree$tip.label)] <- as.vector(sapply(tree$tip.label[grep("sWGA", tree$tip.label)] , function(x) strsplit(x, "_")[[1]][1]))
    simpleTree(tree)

    ## drop outliers in different stages
    # tree = drop.tip(tree, tip = c("Lnaiffi_ERR205764", "LFA-CU-104_SuSL_none"))
    tree = drop.tip(tree, tip = c("Lnaiffi_ERR205764", "LFA-CU-104"))
    simpleTree(tree)
    
    tree = drop.tip(tree, tip = c("Lguyanensis_SRR1662195", "Lshawi_SRR1657909", "Lpanamensis_SRR1662198"))
    simpleTree(tree)
    
    tree = drop.tip(tree, tip = c("LFA-CU-024"))
    tree = drop.tip(tree, tip = c("LFA-CU-009","PER163A1","CUM555A1","CUM663A1"))
    tree = drop.tip(tree, tip = c("PER182A1", "Lb7616"))
    simpleTree(tree, text_size = 2)
    
    
    ## convert to tree to a tibble data frame which can then 
    ## be used to add additional information - metadata. Also
    ## change the naming of the SuSL and drop information on the 
    ## protocol and enrichment method
    x <- as_tibble(tree)
    print(x, n=100)
    
    ## add metadata
    
    x_new = cbind(x, meta_data[match(x$label, meta_data$Sample.Code),])
    tree_new = full_join(tree,x_new)
    simpleTree(tree_new)

    complexTree(tree_new, highlight = 'species')
    p = complexTree(tree_new, highlight = 'Source') 
    p + coord_cartesian(xlim=c(0,0.2), ylim=c(0,100))
    
    p = complexTree(tree_new, highlight = 'Country') 
    p + coord_cartesian(xlim=c(0,0.2), ylim=c(0,100))
    p
    

  }
}






