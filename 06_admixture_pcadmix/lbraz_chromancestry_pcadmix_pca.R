library(ggplot2)
library(openxlsx)

pcadmix_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/ancestry_output.pca.txt'
plot_data = read.table(pcadmix_file)
colnames(plot_data) = c('haplotype', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5')

plot_data$strain = plot_data$haplotype
plot_data$strain = gsub("_A", "", plot_data$strain)
plot_data$strain = gsub("_B", "", plot_data$strain)

## read in the meta data 
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.data_Senne.clonal_isolates_populations.xlsx'
meta_data = read.xlsx(meta_data_file, sheet='meta_data', colNames =FALSE)
colnames(meta_data) = c('strain', 'pop')

plot_data$pop = meta_data[match(plot_data$strain, meta_data$strain),]$pop
plot_data[grep("SuSL", plot_data$strain),]$pop = "SuSL"

ggplot(data = plot_data, aes(x=PC1, y=PC2)) + 
  geom_point(aes(color=pop), size=1.5, alpha=0.5) + 
  theme_bw()


## add the additional added negative controls as a "+" like done
## by Senne
neg_control_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/adm_negcontrol.list'
neg_control = as.vector(read.csv(neg_control_file)[,1])

first_round = 1
for (sample in neg_control) {
  neg_data_new = plot_data[plot_data$strain == sample,]
  neg_data_new = neg_data_new[3:4,]  
  if (first_round == 1) {
    neg_data = neg_data_new
    first_round = 0
  }else{
    neg_data = rbind.data.frame(neg_data, neg_data_new)
  }
}

ggplot(data = plot_data, aes(x=PC1, y=PC2)) + 
  geom_point(aes(color=pop), size=3, alpha=0.5) + 
  geom_point(data = neg_data, aes(x=PC1, y=PC2), shape="+", size=3) +
  theme_bw() 


