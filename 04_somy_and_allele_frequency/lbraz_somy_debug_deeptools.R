library('ggplot2')
library('plyr')
library('patchwork')
library('pheatmap')
library('RColorBrewer')
library('openxlsx')
library('grid')
library(stats)


# this script starts from the coverage values per window of e.g. 10,000nt 
# and gradually implements the 

#### 000 input parameters ####

## input data 
results_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/somy/'

## meta data files
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
# meta_data = read.xlsx(meta_data_file, sheet = 'bam')
meta_data = read.xlsx(meta_data_file, sheet = 'Lbraziliensis.direct_sequencing')
# meta_data$sample_short = paste0(meta_data$name_unified, "_", meta_data$Type)
meta_data$sample_short = paste0(meta_data$name_unified, "_", meta_data$Type, "_", meta_data$protocol)
meta_data$sample_short = gsub("_none", "", meta_data$sample_short)
meta_data$sample_short = gsub("SuSL_baits", "SuSL", meta_data$sample_short)

head(meta_data)

# excluded_regions_file = '/Users/pmonsieurs/programming/leishmania_somy/data/excluded_regions.csv'
bin_width = 10000
depth_file = paste0(results_dir, 'summary.bin_',bin_width,'.filtered.csv')


#### 00. functions to be used ####

# general function to make boxplot for all somy values or coverage
# boxplots 

make_boxplot = function (plot_data, parameter, ylim=NULL, plot_title="somy", highlight=TRUE) {
  print(highlight)
  print(head(plot_data))
  print(parameter)
  print(plot_title)
  # colnames(data) = c('chr', 'start', 'end', parameter)
  p = ggplot(data =plot_data, aes_string(x='chr', y=parameter))
  p = p + geom_boxplot(outlier.size=0.3)
  if (! is.null(ylim)) {
    p = p + coord_cartesian(ylim = c(0, ylim))
  }
  
  p = p + ggtitle(plot_title)
  # p = p + geom_point(data=somy_truth, aes(x=chrom,y=somy), alpha=0.50,size=3) 
  # # p
  # 
  if (highlight) {
    print(highlight)
    # p = p + geom_hline(yintercept = 2, col="red", size=2, alpha=0.5)
    p = p +   annotate("rect", 
                       xmin=0, xmax=37, 
                       ymin=1.5, ymax=2.5, 
                       alpha=0.1, fill="red") 
    p = p +   annotate("rect", 
                       xmin=0, xmax=37, 
                       ymin=2.5, ymax=3.5, 
                       alpha=0.1, fill="yellow") 
    p = p +   annotate("rect", 
                       xmin=0, xmax=37, 
                       ymin=3.5, ymax=4.5, 
                       alpha=0.1, fill="green") 
    
    }
  p = p + theme_bw()
  p = p + theme(axis.text.x = element_text(angle = 90))
  # p = p + labs(x="chromosome", y= paste0("Somy ", plot_title))
  p = p + labs(x="chromosome", y= paste0("Somy"))
  p = p + theme(axis.text=element_text(size=6),
                axis.title=element_text(size=10,face="bold"),
                plot.title = element_text(size = 12, face = "bold"))
  p
  return(p)
}

# calculate median per chromosome, and subsequently the median 
# over the median
get_median_overall = function (depth_data) {
  chrom_cov_medians = c()
  for (chrom in unique(depth_data$chr)) {
    median_cov_chrom = median(depth_data[depth_data$chr == chrom, 4])
    chrom_cov_medians = c(chrom_cov_medians, median_cov_chrom)
  }
  median_cov = median(chrom_cov_medians)
  return(median_cov)
}

# calculate median per chromosome, and subsequently the median 
# over the median
get_sd_overall = function (depth_data) {
  chrom_cov_sd = c()
  for (chrom in unique(depth_data$chr)) {
    if (chrom == "LbrM.31_v4_pilon") {next}
    sd_cov_chrom = sd(depth_data[depth_data$chr == chrom, 4])
    chrom_cov_sd = c(chrom_cov_sd, sd_cov_chrom)
  }
  mean_sd = mean(chrom_cov_sd)
  return(mean_sd)
}

calculate_somy = function(depth_data, somy_col_name) {
  somy_values = c()
  for (chrom in unique(depth_data$chr)) {
    if (chrom == "Ld37") {next}
    somy_chrom = median(depth_data[depth_data$chr==chrom, somy_col_name])
    somy_values = c(somy_values, somy_chrom)
  }
  print(somy_values)
  return(somy_values)
}

calculate_somy_local = function(depth_data, somy_col_name) {
  flanking = 7
  somy_values = c()
  somy_col_name = 'cov'
  chroms =  unique(depth_data$chrom)[-37]
  for (i in 1:length(chroms)) {
    chrom = chroms[i]
    flanking_chroms = chroms[max(0,i-flanking):min(length(chroms), i+flanking)]
    depth_data_sub = depth_data[depth_data$chrom %in% flanking_chroms,]
    cov_sub_median = get_median_overall(depth_data_sub)
    cov_chrom = median(depth_data_sub[depth_data_sub$chrom==chrom, somy_col_name])
    somy_chrom =  2*cov_chrom/depth_data_sub_median
    somy_values = c(somy_values, somy_chrom)
  }
  print(somy_values)
  return(somy_values)
}

calculate_average_somy_deviation = function(somy_data, somy_ref) {
  asd = 0
  for (i in 1:length(somy_data)) {
    asd = asd + abs(somy_data[i] - somy_ref[i])
  }
  asd = asd/length(somy_data)
}

calculate_somy_difference_count = function(somy_data, somy_ref) {
 sdc = 0
 for (i in 1:length(somy_data)) {
   if (is.na(somy_data[i])) {
     return(NA)
   }
   if (abs(somy_data[i] - somy_ref[i]) > 0.5) {
     sdc = sdc + 1
   }
 }
 return(sdc)
 
}


#### 0. read input data ####

# plot raw data of coverage, without any filtering. Any filtering that 
# has been performed at this stage is removing the first and last 10,000nt
# for each chromosome
depth_data = read.csv(depth_file, sep="\t", header=TRUE)

## change the column names
colnames(depth_data) = gsub("X\\.\\.", "", colnames(depth_data))
colnames(depth_data) = gsub("X\\.", "", colnames(depth_data))
colnames(depth_data) = gsub("\\.$", "", colnames(depth_data))
colnames(depth_data) = gsub(".mapq30.removedups.proper_paired.bam", "", colnames(depth_data))
colnames(depth_data) = gsub("\\.", "-", colnames(depth_data))
colnames(depth_data) = gsub("_R1-fastq-gz", "", colnames(depth_data))

## match the genomescan ID with a more informative name based
## on the biology. For the sWGA data, also add the type of 
## enrichment method
colnames(depth_data)
colnames(depth_data)[4:ncol(depth_data)] = meta_data[match(colnames(depth_data)[4:ncol(depth_data)], meta_data$ID_code),]$sample_short

head(depth_data)

## sort based on chromosome name and next based on start position of bin
depth_data = depth_data[order(depth_data$chr, depth_data$start),]

## convert the read counts to CPM (counts per million) values
## by dividing by the column sum using the sweep function
cpm = cbind(depth_data[,1:3], sweep(depth_data[,4:ncol(depth_data)],2,colSums(depth_data[,4:ncol(depth_data)]/1000000), FUN='/'))

## do some checks, and check whether sum of all bins = 1 million
head(cpm)
colSums(cpm[,4:ncol(cpm)]) 

## filter out those chromosomes that are not core chromsomes, but
## unplaced scaffolds. Also, reduce the size of the chromosomes
## names to only the digit 
cpm = cpm[-grep("LbrM.00", cpm$chr),]
cpm = cpm[-grep("maxicircle", cpm$chr),]
cpm$chr = gsub("LbrM.", "", cpm$chr)
cpm$chr = gsub("_v4_pilon", "", cpm$chr)


unique(cpm$chr)
dim(cpm)



#### 1. create boxplots ####


cpm_src = cpm


## create different subset of the cpm data set
type_indices = grep("SuSL", colnames(cpm_src))
type_indices = grep("sWGA_digest", colnames(cpm_src))
type_indices = grep("sWGA_baits", colnames(cpm_src))

sample_indices = grep("LFA", colnames(cpm_src))
sample_indices = grep("Mix", colnames(cpm_src))



indices = intersect(type_indices, sample_indices)
length(indices)
cpm = cpm_src[,c(1:3,indices)]
head(cpm)

## remove sample LFA-CU-104_SuSL as this is L. lainsoni and not L. braziliensis
cpm = cpm[, -which(colnames(cpm) == "LFA-CU-104_SuSL")]
cpm = cpm[, -which(colnames(cpm) == "LFA-CU-104_sWGA_digest")]
head(cpm)


mean_sds = c()
mean_sds_31 = c()

# p_combined = plot_layout(ncol = 5)
plot_count = 0
for (sample_name in colnames(cpm)[4:ncol(cpm)]) {
  print(sample_name)
  
  ## find the strain of the sample, to look up the corresponding ground
  ## truth karyotype
  # sample_short = meta_data[meta_data$genomescan_id == sample_name, ]$sample_short
  sample_short = sample_name
  
  # create empty datafram with one row per chromsosome for
  # which we save the somy value. This somy value is the 
  # median somy value for each of the somy calculations. This
  # basically corresponds to the horizontal line in the boxplots
  somy_df = as.data.frame(unique(cpm$chr))
  colnames(somy_df) = c('chrom')
    
  #### plot raw coverage values ####
  cpm_sub = cpm[,c('chr', 'start', 'end', sample_name)]  
  colnames(cpm_sub)[4] = 'cpm'
  plot_title = paste0('CPM per chrom - ', sample_short)
  # make_boxplot(cpm_sub, 'cpm', 750, plot_title, FALSE)
  
  #### raw somy values ####
  
  # Raw somy values: add the somy value per window by dividing 
  # each coverage by the median value of the coverage over 
  # all chromosomes
  median_cov = get_median_overall(cpm_sub)
  if (median_cov == 0) {
    print("overal median value is ZERO ==> skip sample")
    next
  }
  

  ## only increase plot count here. If not, you can never obtain
  ## a p-combined
  plot_count = plot_count + 1
  
  
  cpm_sub$raw_somy = 2*cpm_sub[,'cpm']/median_cov
  plot_title = paste0(sample_name, ' - Raw somy')
  # make_boxplot(cpm_sub, 'raw_somy', 5, plot_title)
  somy_df$somy_raw = calculate_somy(cpm_sub,'raw_somy')
  
  
  #### local correction ####
  
  # calculate the chromosome based on the flanking regions. 
  
  flanking = 7
  # somy_values = c()
  # somy_col_name = 'cov'
  chroms =  unique(cpm_sub$chr)
  cpm_sub$somy_local = NA
  somy_col_name = 'cpm'
  somy_values = c()
  chrom_sds_sample = c()
  
  for (i in 1:length(chroms)) {
    chrom = chroms[i]
    flanking_chroms = chroms[max(0,i-flanking):min(length(chroms), i+flanking)]
    cpm_sub_sub = cpm_sub[cpm_sub$chr %in% flanking_chroms,]
    cov_sub_median = get_median_overall(cpm_sub_sub)
    cov_chrom = median(cpm_sub_sub[cpm_sub_sub$chr==chrom, somy_col_name])
    # print(cov_chrom)
    # print(cov_sub_median)
    cov_chrom = cpm_sub_sub[cpm_sub_sub$chr == chrom,'cpm']
    somy_chrom_local =  2*cov_chrom/cov_sub_median
    
    chrom_sd = sd(somy_chrom_local)
    
    if (chrom == "31") {
      mean_sds_31 = c(mean_sds_31, chrom_sd)
    }else{
      chrom_sds_sample = c(chrom_sds_sample, chrom_sd)
    }
    cpm_sub[cpm_sub$chr == chrom,]$somy_local = somy_chrom_local
    print(median(somy_chrom_local))
    somy_values = c(somy_values, median(somy_chrom_local))
  }
  # print(somy_values)
  
  plot_title = sample_short
  
  mean_sds = c(mean_sds, mean(chrom_sds_sample))
  
  
  ## create boxplot and merge the boxplot with the overall patchwork 
  ## object to make summary plot
  p = make_boxplot(cpm_sub, 'somy_local', 5, plot_title)
  if (plot_count == 1) {
    p_combined = p
  }else{
    p_combined = p_combined + p
  }
  
}

p_combined

mean(mean_sds)
median(mean_sds)

median(mean_sds_31)




nr_of_columns = 4
p_combined = p_combined + plot_layout(ncol = nr_of_columns)

unit = 6
width = nr_of_columns * unit
height = unit * ceiling((ncol(cpm)-3)/3)
# height=unit
width = 12
height = 12

boxplot_file = paste0(results_dir, 'boxplots_combined.png')
ggsave(boxplot_file, 
       p_combined, 
       width=width,
       height=height,
       limitsize = FALSE, 
       dpi=300)


##### 2. Heatmap of somy values ###

## create heatmap with the difference between the predicted and the actual
## somy value. We have to remove the control samples here

stats_merged = merge(stats, meta_data, by.x=0, by.y='Code.GenomeScan')
# stats_merged = stats_merged[-c(5,10,22),]

breaks = seq(-0.4,0.4,0.02)
# pheatmap(stats[,3:ncol(stats)],
pheatmap(stats_merged[,4:39],
         cluster_rows=FALSE, 
         cluster_cols=FALSE,
         breaks=breaks,
         color=colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(length(breaks)),
         labels_row = gsub(" Leishmania DNA", "", stats_merged$print_name),
         labels_col = paste0(colnames(stats_merged)[4:39], "     ")) ## add spaces to increase margin
setHook("grid.newpage", NULL, "replace")
grid.text("Chromosome", x=0.40, y=0.03, gp=gpar(fontsize=16, fontface = "bold"))

ggsave('heatmap_somydeviation.png')

output_file = paste0(results_dir, 'somy_stats.xlsx')
stats = merge(meta_data, stats, by.x="Code.GenomeScan", by.y=0)
write.xlsx(stats, output_file)

##### Additional Code #####


### GC-percentage of chromosome versus somy value. 
## GC percentage of chromosomes is obtained from data from the 
## single cell manuscript (picoplex)
GC_per_chrom_file = '/Users/pmonsieurs/programming/leishmania_singlecell/data/genomes/Leishmania_donovani_16Nov2015beta.gc.csv'
gc_data = read.csv(GC_per_chrom_file, header=TRUE)
gc_vs_somy_data = as.data.frame(gc_data[-37, c('chrom', 'gc_perc')])
gc_vs_somy_data
gc_vs_somy_data = cbind(gc_vs_somy_data, somy_df$somy_local)
colnames(gc_vs_somy_data)[3] = 'somy'
rownames(gc_vs_somy_data) = gc_vs_somy_data$chrom

# remove Ld31
gc_vs_somy_data = gc_vs_somy_data[-which(gc_vs_somy_data$chrom=="Ld31"),]

plot_title = paste0(strain, ' - ', method, ' - somy versus %GC')


p = ggplot(gc_vs_somy_data, aes(x=gc_perc, y=somy))
p = p + geom_point(color="blue", size=2, alpha=0.75)
p = p + stat_smooth(method="lm", color="red", span=2, alpha=.50)
p = p + theme_bw()
p = p + geom_text(aes(label=chrom), hjust=-0.25, vjust=-0.10, size=3)
p = p + coord_cartesian(ylim=c(1.5,2.5))
p = p + ggtitle(plot_title)
p 

# make manhattan plot
depth_data$cum_pos = seq(1,dim(depth_data)[1]*bin_width, bin_width)

p = ggplot(depth_data, aes(x=cum_pos, y=cov))
p = p + geom_point(aes(colour=chrom), size=0.50, alpha=0.50)
p = p + scale_color_manual(values = rep(c("#276FBF", "#183059"), 
                                        length(unique(depth_data$chrom))))

p = p + coord_cartesian(ylim = c(0, 1000))
p = p + stat_smooth(method="loess", color="red", span=0.10, alpha=.50)
p

