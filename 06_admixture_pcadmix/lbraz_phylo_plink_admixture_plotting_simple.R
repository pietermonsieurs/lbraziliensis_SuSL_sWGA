library(ggplot2)
library(dplyr)
library(reshape)
library(openxlsx)

data_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/final/admixture/'

#### 1. input data ####

K_min=4
K_max=6

## samples to be removed (identified as low-quality samples in the 
## paper of Senne)
samples_to_be_removed = c('CUM68A1', 'LC2318A1', 'PER231A1')


## define here for wchich type of data you want to plot. The options are 'SuSL' or 'sWGA', and 
## for sWGA you can specify the protocol (digest or baits)
# type = 'SuSL'
type = 'sWGA'
protocol = 'digest'
protocol = 'baits'

for (K in K_min:K_max) {
  
  # ---- 1.1. meta data ----
  ## read in the metadata, which is a copy of the pv genomes excel file
  meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
  meta_data = read.xlsx(meta_data_file, sheet = "metadata_phylo")
  # meta_data = subset(meta_data, type=="SuSL" | type=="WGS")
  if (type == "SuSL") {
    meta_data = subset(meta_data, type=="SuSL" | type=="WGS")
  }else if (type == "sWGA") {
    meta_data = meta_data[meta_data$type=="WGS" | (meta_data$type=="sWGA" & meta_data$protocol == protocol),]
  }
  head(meta_data)
  
  ## artificially add three WGS samples of the Lbraz lineage 2 to
  ## the metadata frame
  missing_wgs = c("CUM663A1", "CUM555A1", "PER163A1")
  meta_data_add = data.frame(Sample.Code = missing_wgs)
  
  missing_cols <- setdiff(names(meta_data), names(meta_data_add))
  # Create new columns in new_data and set them as NA
  for (col in missing_cols) {
    meta_data_add[[col]] <- NA
  }
  meta_data = rbind(meta_data, meta_data_add)
  
  
  
  # ---- 1.2 admixture data ----
  ## the .fam file specifies the order of the samples in the output of the 
  ## admixture output 
  # sample_order_file = paste0(data_dir, 'phylo.biallelic.complete.ldpruned.fam')
  if (type == 'SuSL') {
    sample_order_file = paste0(data_dir, 'phylo.biallelic.complete.ldpruned.fam')
  }else if (type == 'sWGA') {
    sample_order_file = paste0(data_dir, 'phylo.',type,'_',protocol,'.biallelic.complete.ldpruned.fam')
  }
  # sample_order_file = paste0(data_dir, 'phylo.biallelic.comprotocolsample_order_file = paste0(data_dir, 'phylo.biallelic.complete.ldpruned.fam')
  sample_order = read.table(sample_order_file, sep="\t")[,2]
  sample_order
  sample_order = sapply(strsplit(as.character(sample_order), "_", fixed = TRUE), "[", 1)
  
  
  ## filter + order the metadata
  meta_data_filter = meta_data[meta_data$Sample.Code %in% sample_order,]
  # meta_data_filter_sort= meta_data_filter[order(meta_data_filter$sra_number),]
  dim(meta_data_filter)
  
  # ---- 1.3 read in the admixture data ----
  ## read the assignment probabilities. This should be done
  ## using the K-value obtained from the cross validation 
  ## experiment 
  admixture_dir = data_dir
  if (type == 'SuSL') {
    admixture_output_file = paste0(admixture_dir, 'phylo.biallelic.complete.ldpruned.',K,'.Q')
  }else if (type == 'sWGA') {
    admixture_output_file = paste0(admixture_dir, 'phylo.',type,'_',protocol,'.biallelic.complete.ldpruned.',K,'.Q')
  }
  
  admixture_output = read.table(admixture_output_file)
  
  ## specify the column names, as they correspond to the probability that 
  ## a sample belongs to an admixture group. Also add the rownames by 
  ## the sample_order
  colnames_adm_output = paste0("K", seq(1,K,1))
  colnames(admixture_output) = colnames_adm_output
  rownames(admixture_output) = sample_order
  admixture_output$sample = sample_order
  # admixture_output = admixture_output[, -ncol(admixture_output)]
  head(admixture_output)
  
  ## clean out the bad samples
  admixture_output = admixture_output[! admixture_output$sample %in% samples_to_be_removed,]
  dim(admixture_output)

  #### 2. visualisation ####
  
  # ---- 2.1 sorting the samples according to the groups ----
  
  ## specify the dominant group as the cluster with the highes probability
  ## and add this as a separate column
  admixture_output$group = apply(admixture_output,1,which.max) 
  
  ## give rownames as sample names
  ##rownames(admixture_output) = meta_data_filter_sort$search_name_print # !!! WRONG !!!
  index_for_meta_data = match(admixture_output$sample, meta_data_filter$Sample.Code)
  plot_data = cbind(meta_data_filter[index_for_meta_data,c('Sample.Code', 'protocol', 'inferred_group', 'Country', 'Source')], admixture_output)
  sum(plot_data$sra_number == plot_data$sample, na.rm=TRUE) == nrow(plot_data)
  head(plot_data)
  
    ## Alternative approach II: do correlation analysis and group them
  ## according to hierarchical clustering
  head(plot_data)
  K_data = plot_data[,6:(6+K-1)]
  distance_matrix <- dist(K_data, method = "euclidean")
  clustering <- hclust(distance_matrix, method = "complete")
  plot_data_sorted = plot_data[clustering$order,]
  
  
  ## remove the last column (group) as otherwise this will be
  ## added to the plot data
  plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
  plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
  head(plot_data_sorted)
  
  ## add the maximum number of Ks (populations) that were 
  ## looked for
  plot_data_sorted$K_max = K
  
  ## update the sample Code
  plot_data_sorted$Sample.Code = gsub("A1$", "", plot_data_sorted$Sample.Code)
  
  
  ## melt the plot_data
  plot_data_sorted_melt = melt(plot_data_sorted, id=c('Sample.Code', 'protocol', 'inferred_group', 'Country', 'Source', 'K_max'))
  plot_data_sorted_melt$Sample.Code = factor(plot_data_sorted_melt$Sample.Code, levels=plot_data_sorted$Sample.Code)
  plot_data_sorted_melt = plot_data_sorted_melt[! is.na(plot_data_sorted_melt$Sample.Code),]
  
  ## merge with the overall data frame
  if (K == K_min) {
    plot_data_sorted_melt_all = plot_data_sorted_melt
  }else{
    plot_data_sorted_melt_all = rbind.data.frame(plot_data_sorted_melt_all, plot_data_sorted_melt)
  }
  
}

saveRDS(plot_data_sorted_melt_all, paste0(data_dir, 'admixture_df_for_senne.rds'))


admix_plot = ggplot(plot_data_sorted_melt_all, aes(fill=variable, y=value, x=Sample.Code)) + 
  geom_bar(position="fill", stat="identity") + 
  scale_fill_brewer(palette="Set3") + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=9),
        axis.text.y = element_text(size=10),
        strip.text = element_text(size = 10),
        legend.text = element_text(size = 10),
        legend.title = element_text(size= 10)) + #,
        #legend.title = element_blank()) + 
  labs(x="", y="", fill="population") +
  facet_wrap(~ K_max, ncol=1)

admix_plot

if (type == "SuSL") {
  svg_file = paste0(data_dir, 'admixture_plot_SuSL.svg') 
}else{
  svg_file = paste0(data_dir, 'admixture_plot_sWGA_', protocol, '.svg')
}
ggsave(filename = svg_file,
       plot = admix_plot,
       dpi = 300)



if (type == "SuSL") {
  png_file = paste0(data_dir, 'admixture_plot_SuSL.png') 
}else{
  png_file = paste0(data_dir, 'admixture_plot_sWGA_', protocol, '.png')
}
ggsave(filename = png_file,
       plot = admix_plot,
       dpi = 300)

#### PCA analysis




# ---- 3.1 read in the data and link metadata ----

enrich_types = c('SuSL', 'sWGA_digest', 'sWGA_baits')
fractions = c('0.5', '0.95')

first_sample = 1
for (enrich_type in enrich_types) {
  for (fraction in fractions) {
    pca_file = paste0(data_dir, 'phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.lbraz.snps.',complete,'ldpruned.eigenvec')
    pca_data = read.table(pca_file, sep="\t")
    pca_data = pca_data[,-1]
    colnames(pca_data) = c('sample', 'PC1', 'PC2', 'PC3', 'PC4', 'PC5')
    head(pca_data)
    
    ## color the samples of interest (sWGA etc.)
    pca_data[,'type'] = NA
    pca_data[grep("LFA-", pca_data[,1]),]$type = enrich_type
    
    ## add the type of sample to be able to run
    ## facet_wrap
    pca_data$dataset = paste0(enrich_type, " - ", fraction)
    
    ## check if first sample
    if (first_sample) {
      pca_data_all = pca_data
      first_sample = 0
    }else{
      pca_data_all = rbind.data.frame(pca_data_all, pca_data)
    }
  }
}

# head(meta_data_filter_sort)
# head(cbind(pca_data, meta_data_filter_sort))
ggplot(pca_data_all, aes(x=PC1,y=PC2)) + 
  geom_point(aes(fill=type), alpha=1, colour="black",pch=21, size=3) + 
  theme_bw() + 
  facet_wrap(~ dataset)



## Optional code if we would like to add metadata at 
## a later stage

## select only those sample which are present in the meta data and
## sort them according to the sample name (search_name_print)
meta_data_filter = meta_data[meta_data$Sample.Code %in% pca_data[,1],]
meta_data_filter_sort= meta_data_filter[order(meta_data_filter$Sample.Code),]
head(meta_data_filter_sort)


## also sort the PCA data according to the sample name and sort 
## them according to first column (=sample name). 
pca_data_sorted = pca_data[order(pca_data[,1]),]

## Also check whether the sample names are in the same order
## before merging
sum(pca_data_sorted$V1 == meta_data_filter_sort$search_name_print)
dim(pca_data_sorted)

## do combination of both data frames
plot_data_pca = cbind(pca_data_sorted, meta_data_filter_sort)
head(plot_data_pca)
colnames(plot_data_pca)[2:6] = c('PC1', 'PC2', 'PC3', 'PC4', 'PC5')
colnames(plot_data_pca)[2:6] = c('PC1', 'PC2', 'PC3', 'PC4', 'PC5')
head(plot_data_pca)


# ---- 3.2 make plot using Population level analysis ---
ggplot(plot_data_pca, aes(x=PC1,y=PC2)) + 
  geom_point(aes(fill=), alpha=1, colour="black",pch=21, size=3) + 
  theme_bw()

ggplot(plot_data_pca, aes(x=PC3,y=PC4)) + 
  geom_point(aes(fill=Population), alpha=1, colour="black",pch=21, size=3) + 
  theme_bw()














##########OLD CODE ___ PER SAMPLE ###########

# ---- 1.1. meta data ----
## read in the metadata, which is a copy of the pv genomes excel file
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
meta_data = read.xlsx(meta_data_file, sheet = "metadata_phylo")
meta_data = subset(meta_data, type==enrich_type | type=="WGS")
head(meta_data)


# ---- 1.2 admixture data ----
## the .fam file specifies the order of the samples in the output of the 
## admixture output 


sample_order_file = paste0(data_dir, 'phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.lbraz.snps.ldpruned.fam')
sample_order = read.table(sample_order_file, sep="\t")[,2]
sample_order
sample_order = sapply(strsplit(as.character(sample_order), "_", fixed = TRUE), "[", 1)


## filter + order the metadata
meta_data_filter = meta_data[meta_data$Sample.Code %in% sample_order,]
# meta_data_filter_sort= meta_data_filter[order(meta_data_filter$sra_number),]


# ---- 1.3 read in the admixture data ----
## read the assignment probabilities. This should be done
## using the K-value obtained from the cross validation 
## experiment 
admixture_dir = data_dir
admixture_output_file = paste0(admixture_dir, 'phylo.',enrich_type,'.filtered_stringent.renamed2.fraction',fraction,'.lbraz.snps.ldpruned.',K,'.Q')
admixture_output = read.table(admixture_output_file)

## specify the column names, as they correspond to the probability that 
## a sample belongs to an admixture group. Also add the rownames by 
## the sample_order
colnames_adm_output = paste0("K", seq(1,K,1))
colnames(admixture_output) = colnames_adm_output
rownames(admixture_output) = sample_order
admixture_output$sample = sample_order
# admixture_output = admixture_output[, -ncol(admixture_output)]
head(admixture_output)
dim(admixture_output)


## using NetView
# plotAdmixture(admixture_output_file, graph=NULL, structurePlot=FALSE, palette="Dark2", colourN=8)
# plotAdmixture(admixture_output_file, metaData=meta_data_filter)


# d <- dist(admixture_output)
# h <- hclust(d)
# dend <- as.dendrogram(h)
# plot(dend)


#### 2. visualisation ####

# ---- 2.1 sorting the samples according to the groups ----

## specify the dominant group as the cluster with the highes probability
## and add this as a separate column
admixture_output$group = apply(admixture_output,1,which.max) 

## give rownames as sample names
##rownames(admixture_output) = meta_data_filter_sort$search_name_print # !!! WRONG !!!
index_for_meta_data = match(admixture_output$sample, meta_data_filter$Sample.Code)
plot_data = cbind(meta_data_filter[index_for_meta_data,c('Sample.Code', 'protocol', 'inferred_group', 'Country', 'Source')], admixture_output)
sum(plot_data$sra_number == plot_data$sample, na.rm=TRUE) == nrow(plot_data)
head(plot_data)




## sort the different samples according to the group where they belong to 
## and next to the probability per group: ugly solution - still find a way 
## to sort by multiple columsn names which are defined as variables
# if (K==5) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5)),]}
if (K==7) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5, -K6, -K7)),]}
if (K==10) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5, -K6, -K7, -K8, -K9, -K10)),]}
# if (K==11) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5, -K6, -K7, -K8, -K9, -K10, -K11)),]}
# if (K==20) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5, -K6, -K7, -K8, -K9, -K10, -K11, -K12, -K13, -K14, -K15, -K16, -K17, -K18, -K19, -K20)),]}
# if (K==21) {plot_data_sorted = plot_data[with(plot_data, order(group, -K1, -K2, -K3, -K4, -K5, -K6, -K7, -K8, -K9, -K10, -K11, -K12, -K13, -K14, -K15, -K16, -K17, -K18, -K19, -K20, -K21)),]}


## alternative approach for plot_data_sorted, where you select per group
## the subset of data, and sort them according to the group that is selected. 
## this gives nicer plots than the code above, as you sort per dominant group
## according to that group
plot_data_sorted = data.frame()
for (K_value in 1:K) {
  plot_data_sub = plot_data[plot_data$group == K_value,]
  colname = paste0("K", K_value)
  plot_data_sub_sorted = plot_data_sub[order(plot_data_sub[,colname], decreasing = TRUE),]
  if (K_value == 1) {
    plot_data_sorted = plot_data_sub_sorted
  }else{
    plot_data_sorted = rbind.data.frame(plot_data_sorted, plot_data_sub_sorted)
  }
}
head(plot_data_sorted)


## remove the last column (group) as otherwise this will be
## added to the plot data
plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
head(plot_data_sorted)



## Alternative approach II: do correlation analysis and group them
## according to hierarchical clustering
head(plot_data)
K_data = plot_data[,6:(6+K-1)]
distance_matrix <- dist(K_data, method = "euclidean")
clustering <- hclust(distance_matrix, method = "complete")
plot_data_sorted = plot_data[clustering$order,]

plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
plot_data_sorted = plot_data_sorted[,-ncol(plot_data_sorted)]
head(plot_data_sorted)

# ---- 2.2 plot the different groups in a barplot ----

## melt the plot data to work with ggplot
# plot_data_sorted_melt = melt(plot_data_sorted, id=c('sample_name', 'sra_number', 'sample_id', 'ISC'))
plot_data_sorted_melt = melt(plot_data_sorted)
# plot_data_sorted_melt$sra_number = factor(plot_data_sorted_melt$sra_number, levels=plot_data_sorted$sra_number)
plot_data_sorted_melt$Sample.Code = factor(plot_data_sorted_melt$Sample.Code, levels=plot_data_sorted$Sample.Code)
plot_data_sorted_melt$x_axis = paste0(plot_data_sorted_melt$sra_number, ":", plot_data_sorted_melt$Sample.Code)
# plot_data_sorted_melt$x_axis = factor(plot_data_sorted_melt$x_axis, plot_data_sorted_melt$x_axis)
head(plot_data_sorted_melt)

## specify the colors. One way is to work with a set of predefined
## colors and use e.g. scale_fill_brewer(palette="Set3"), but not always
## enough colors present. So you can create your own color scheme starting from 
## exsiting one and use "scale_fill_manual(values = ...)
cols = brewer.pal(n = 8, name = "Dark2")
# cols = palette.colors(n = 9, palette = "Okabe-Ito") # https://jfly.uni-koeln.de/color/#pallet
col.palette <- colorRampPalette(cols,
                                space = "Lab")


## create the admixture plot
ggplot(plot_data_sorted_melt, aes(fill=variable, y=value, x=Sample.Code)) + 
  geom_bar(position="fill", stat="identity") + 
  # theme(axis.text.x=element_blank(), #remove x axis labels
  #       axis.ticks.x=element_blank()) + 
  scale_fill_manual(values = col.palette(K))
  # scale_fill_brewer(palette="Set3")

ggplot(plot_data_sorted_melt, aes(fill=variable, y=value, x=Sample.Code)) + 
  geom_bar(position="fill", stat="identity") + 
  scale_x_discrete(plot_data_sorted_melt$Sample.Code) + 
    # theme(axis.text.x=element_text(plot_data_sorted_melt$sample_id), #remove x axis labels
  #       axis.ticks.x=element_blank()) + 
  # #scale_fill_manual(values = col.palette(K+1))
  scale_fill_brewer(palette="Set3") + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=6))


# ---- 2.3 create the side bars ----

## create the side bar for the bar plot to show the country or the 
plot_data_artificial = plot_data_sorted
plot_data_artificial$search_name_print = factor(plot_data_artificial$search_name_print, levels=plot_data_artificial$search_name_print)


cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

plot_data_artificial$dummy = 1
ggplot(plot_data_artificial, aes(fill=Population, y=dummy, x=search_name_print)) + 
  geom_bar(position="fill", stat="identity") + 
  theme(axis.text.x=element_blank(), #remove x axis labels
        axis.ticks.x=element_blank()) + 
  scale_fill_manual(values = cbPalette)
  #scale_fill_brewer(palette="Set3")
  

ggplot(plot_data_artificial, aes(fill=Country, y=dummy, x=search_name_print)) + 
  geom_bar(position="fill", stat="identity") + 
  theme(axis.text.x=element_blank(), #remove x axis labels
        axis.ticks.x=element_blank()) + 
  scale_fill_manual(values = cbPalette)


ggplot(plot_data_artificial, aes(fill=year, y=dummy, x=search_name_print)) + 
  geom_bar(position="fill", stat="identity") + 
  theme(axis.text.x=element_blank(), #remove x axis labels
        axis.ticks.x=element_blank()) + 
  scale_fill_continuous(limits=c(2000,2020), 
                        breaks=seq(2000,2020,10),
                        
                        guide=guide_colourbar(reverse = TRUE))
  # scale_fill_gradientn(limits = c(2000, 2020),
  #                       breaks=seq(2000,2020,1),
  #                      colours=c("grey90", viridis::inferno(10000, begin = 0, end = 1, direction = -1)))
                        # colours = rev(heat.colors(length(seq(2000,2020,1)))))


plot.admixture('/Users/pmonsieurs/programming/plasmodium_pvgenomes/results/admixture/')







#### 3. PCA visualisation ####

# ---- 3.1 read in the data and link metadata ----
pca_file = '/Users/pmonsieurs/programming/plasmodium_pvgenomes/results/admixture/pca_results.SAM.eigenvec'
pca_file = '/Users/pmonsieurs/programming/plasmodium_pvgenomes/results/admixture/PvP01_v1.no_outliers.pca_results.eigenvec'
pca_data = read.table(pca_file, sep="\t")
head(pca_data)

# head(meta_data_filter_sort)
# head(cbind(pca_data, meta_data_filter_sort))

## select only those sample which are present in the meta data and
## sort them according to the sample name (search_name_print)
meta_data_filter = meta_data[meta_data$search_name_print %in% pca_data$V1,]
meta_data_filter_sort= meta_data_filter[order(meta_data_filter$search_name_print),]
head(meta_data_filter_sort)


## also sort the PCA data according to the sample name and sort 
## them according to first column (=sample name). 
pca_data_sorted = pca_data[order(pca_data$V1),]

## Also check whether the sample names are in the same order
## before merging
sum(pca_data_sorted$V1 == meta_data_filter_sort$search_name_print)
dim(pca_data_sorted)

## do combination of both data frames
plot_data_pca = cbind(pca_data_sorted, meta_data_filter_sort)
head(plot_data_pca)
colnames(plot_data_pca)[2:6] = c('PC1', 'PC2', 'PC3', 'PC4', 'PC5')
colnames(plot_data_pca)[2:6] = c('PC1', 'PC2', 'PC3', 'PC4', 'PC5')
head(plot_data_pca)


# ---- 3.2 make plot using Population level analysis ---
ggplot(plot_data_pca, aes(x=PC1,y=PC2)) + 
  geom_point(aes(fill=Population), alpha=1, colour="black",pch=21, size=3) + 
  theme_bw()

ggplot(plot_data_pca, aes(x=PC3,y=PC4)) + 
  geom_point(aes(fill=Population), alpha=1, colour="black",pch=21, size=3) + 
  theme_bw()


# ---- 3.3 make plot using Country level analysis ---

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

ggplot(plot_data_pca, aes(x=PC1,y=PC2)) + 
  geom_point(aes(fill=Country), alpha=1, colour="black",pch=21, size=3) + 
  #geom_text(aes(label=V1), vjust=1,hjust=1) +
  scale_fill_manual(values = cbPalette) + 
  theme_bw()

ggplot(plot_data_pca, aes(x=PC1,y=PC2)) + 
  geom_point(aes(fill=year), alpha=1, colour="black",pch=21, size=3) + 
  #geom_text(aes(label=V1), vjust=1,hjust=1) +
  theme_bw() + 
  scale_fill_continuous(limits=c(2000,2020), 
                        breaks=seq(2000,2020,10),
                        guide=guide_colourbar(reverse = TRUE))

ggplot(plot_data_pca, aes(x=PC3,y=PC4)) + 
  geom_point(aes(fill=Country), alpha=1, colour="black",pch=21, size=3) + 
  scale_fill_manual(values = cbPalette) + 
  theme_bw()



# --- 3.4 add admixture information to PCA plot? ----

## to be implemented ##



## functions to be loaded? ###
plot.admixture<-function(directory){
  
  require(reshape2)
  require(grid)
  require(ggplot2)
  require(plyr)
  require(RColorBrewer)
  
  Qmatrix <- dir(directory,pattern="*.Q")
  fam<-dir(directory, pattern="*.fam")
  temp.name<-read.csv(paste(directory, fam, sep=""), sep="\t", header=FALSE)
  
  imax<-function(x,n){
    tmp<-as.data.frame(cbind(x, 1:length(x)))
    colnames(tmp)<-c("val","index")
    stmp<-tmp[order(tmp$val, decreasing=TRUE),]
    return(stmp$index[n])
  }
  vmax<-function(x,n){
    tmpd<-sort(x, decreasing=TRUE)
    return(tmpd[n])
  }
  
  parse.Q.files<-function(x){
    dat<-read.csv(file=paste(directory,x, sep=""), sep=" ",header=FALSE)
    ldat<-length(dat)
    
    outter <- NULL	
    
    for(i in 1:ldat){	
      outter<-c(outter,list(apply(dat, 1, FUN=imax, n=i)))
      outter<-c(outter,list(apply(dat, 1, FUN=vmax, n=i)))
    }
    
    dat<-cbind(temp.name$V2,dat)
    colnames(dat)<-c( "names", 1:ldat)
    
    dat<-dat[do.call(order, outter),]
    dat$ov<-1:length(dat$names)
    
    dat2<-melt(dat, id.vars=c("names", "ov"))	
    
    
    dat2$Krun<-ldat
    colnames(dat2)<-c("Name","ov","Admixture.Group","Value", "Krun")
    
    
    return(dat2)
  }	
  
  
  
  plotgg<-function(datframe){
    
    my.max.k<-max(as.numeric(as.character(datframe$Admixture.Group)))
    
    
    datframe<-datframe[order(datframe$ov),]
    datframe$Name<-factor(datframe$Name, levels=datframe$Name, ordered=TRUE)
    
    my.col<-colors()[c(26,547,498,69,33,51,536,100,76,200,300,400,450)]
    
    the.plot<-ggplot(datframe, aes(x=Name, y=Value, fill=Admixture.Group))+geom_bar(stat="identity")
    the.plot<-the.plot+scale_fill_manual(values = my.col[1:my.max.k], name="Admixture group")
    the.plot<-the.plot+theme_classic(18)
    the.plot<-the.plot+theme(axis.text.x = element_text(angle = 90, hjust = 1))
    the.plot<-the.plot+labs(x="Individual", y="fraction ancestry")
    the.plot
    
  }
  
  fdat<-ldply(Qmatrix, parse.Q.files, .inform=TRUE)
  
  my.plots<-dlply(fdat, .(Krun), plotgg)
  
  return(my.plots)
  
}



plot.all.together<-function(file.name, plotCols, list.of.plots){
  
  numPlots = length(list.of.plots)
  plotRows = ceiling(numPlots/plotCols)
  # Fiddle with the to adjust your plot dimentions 
  pdf(file=paste(file.name, "pdf", sep="."),bg="transparent", width=18*plotCols, height=8*plotRows)
  
  grid.newpage() 
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols))) 
  vplayout <- function(x, y) 
    viewport(layout.pos.row = x, layout.pos.col = y) 
  
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(my.plots[[i]], vp = vplayout(curRow, curCol ))
  }
  
  dev.off() 
  
}

