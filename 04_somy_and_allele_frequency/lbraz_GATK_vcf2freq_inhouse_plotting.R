library(ggplot2)
library(ggExtra)
library(ggrepel)

## settings for Morocco data
data_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/bwa_tropica_morocco/allele_freqs/'
allele_freq_file = paste0(data_dir, 'allele_freqs_inhouse.csv')
allele_freq_file = paste0(data_dir, 'allele_freqs_inhouse_all.csv')

## settings for the Lbraz SuSL paper
data_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/allele_freqs_inhouse/'
allele_freq_file = paste0(data_dir, 'allele_freqs.txt')

## read in the allele frequency file
freq_data = read.csv(allele_freq_file, header=FALSE)
colnames(freq_data) = c('sample', 'chrom', 'pos', 'gt', 'freq')
head(freq_data)         

## select only the unique chromosomes, and remove the scaffold like chromosomes. 
## optionally overwrite with those chromosomes you are interested in
chroms = unique(freq_data$chrom)
chroms = chroms[! grepl("SCAF", chroms)]
chroms = chroms[! grepl("LbrM.00", chroms)]

chroms = c("LbrM.04_v4_pilon", "LbrM.18_v4_pilon" )
chroms = c("LbrM.17_v4_pilon", "LbrM.30_v4_pilon" )
chroms


## check the samples, and choose to run for all samples, or a hard-coded list
## of predefined samples
unique(freq_data$sample)
subset_samples = unique(freq_data$sample)
subset_samples = c("LFA-CU-056_SuSL_baits", "LFA-CU-058_SuSL_baits", "LFA-CU-030_SuSL_none")


## plot the allele frquencies for the samples included in the admixture analysis
plot_list_combined = list()
for (chrom in chroms) {
  ## only select data from a specific chromosome. Optionally also select only
  ## a few samples (suspects of hybrids + controls)
  plot_data_chrom = freq_data[freq_data$chrom == chrom,]
  
  plot_list = list()
  
  for (sample in subset_samples) {
    plot_data = plot_data_chrom[plot_data_chrom$sample == sample,]
    
    
    ## create title name
    title = gsub("LFA-", "", sample)
    title = gsub("_SuSL_baits", "", title)
    title = gsub("_SuSL_none", "", title)
    title = gsub("-", "", title)
    
    chrom_title = gsub("LbrM.", "", chrom)
    chrom_title = gsub("_v4_pilon", "", chrom_title)
    
    
    ## create the histograms
    p1 <- ggplot(plot_data, aes(pos, freq)) +
      geom_point(alpha = .75, color = "steelblue") +
      theme_bw() +
      xlab(paste0("Chromosome ", chrom_title)) + 
      ylab("Alternate allele frequency") + 
      ggtitle(title)
      
    
    p2 <- ggplot(
      subset(plot_data, freq > 0.05 & freq < 0.95),
      aes(x = freq)
    ) +
      geom_histogram(
        binwidth = 0.04,
        fill = "grey80",
        color = "white"
      ) +
      geom_density(
        aes(y = after_stat(count * 0.04)),  # <-- this trick guarantees that we are showing counts. If not, we get the frequency density, which is not what we want here
        color = "steelblue",
        linewidth = 1
      ) +
      theme_bw() + 
      coord_flip() + 
      theme(axis.text.y = element_blank(),
            axis.ticks.y = element_blank()) +
      xlab("") + ylab("Count")
    
    
    plot = p1 + p2 + plot_layout(widths = c(4, 1))
    plot
    
    plot_list[[sample]] = plot
  }  
  
  plot_combined = wrap_plots(plot_list, ncol=1)
  
  png_file = paste0(data_dir, 'allele_freqs_', chrom, '.png')
  ggsave(plot, filename = png_file, width=16, height=9)
  
  plot_list_combined[[chrom]] = plot_combined
}

p = wrap_plots(plot_list_combined, ncol=2)
p

plot_file = paste0(data_dir, 'Figure2B.png')
plot_file = paste0(data_dir, 'Figure6.png')
ggsave(p, filename = plot_file, width=16, height=9, dpi=300)




## create the plot from chromosome 17 of FJ20_08, as this one is monosomic
## in the SureSelect data, and disomic in the isolate
dim(freq_data)
head(freq_data)

## only select those data from FJ20_08, and remove the chromsomese with
## SCAF
data_FJ2008 = freq_data[grep("FJ20_08", freq_data$sample),]
data_FJ2008 = data_FJ2008[!grepl("SCAF", data_FJ2008$chrom),]
data_FJ2008$type = sub(".*_(SuSL|WGS)$", "\\1", data_FJ2008$sample)
head(data_FJ2008)

## same as previous plot, but also include a few other samples to check 
## whether the WGS approach of FJ20_08 is the same in other samples. Use the 
## one without admixture
chrom = "LtrL590_17"

## only select data from a specific chromosome. Optionally also select only
## a few samples (suspects of hybrids + controls)
plot_data = freq_data[freq_data$chrom == chrom,]
subset_samples = c('FJ20_08_WGS', 'FJ20_08_SuSL', 'FJ20_11_WGS', 'FJ20_02_SuSL', 'FJ20_12_WGS')
plot_data = plot_data[plot_data$sample %in% subset_samples,]

ggplot(plot_data, aes(x=pos, y=freq)) + 
  geom_point(aes(color=sample), alpha=.50) +
  theme_minimal()

plot = ggplot(plot_data, aes(x=pos, y=freq)) + 
  geom_point(alpha=.50) +
  theme_bw() + 
  facet_wrap(~ sample, ncol=1)
plot

png_file = paste0(data_dir, 'allele_freqs_', chrom, '.png')
ggsave(plot, filename = png_file, width=16, height=9)


## check homozygote stretches in subset of chromosomes selected by eye by 
## JC --> check with other "normal" genomes

chrom_homo_stretches = c('LtrL590_19', 'LtrL590_20', 'LtrL590_27', 'LtrL590_29', 'LtrL590_33', 'LtrL590_34')

for (chrom in chrom_homo_stretches) {
  # chrom = "LtrL590_01"
  
  ## only select data from a specific chromosome. Optionally also select only
  ## a few samples (suspects of hybrids + controls)
  plot_data = freq_data[freq_data$chrom == chrom,]
  subset_samples = c('F28_SuSL', 'FJ20_08_SuSL', 'FJ20_11_WGS', 'FJ20_02_SuSL', 'FJ20_12_WGS')
  plot_data = plot_data[plot_data$sample %in% subset_samples,]
  
  ggplot(plot_data, aes(x=pos, y=freq)) + 
    geom_point(aes(color=sample), alpha=.50) +
    theme_minimal()
  
  plot = ggplot(plot_data, aes(x=pos, y=freq)) + 
    geom_point(alpha=.50, color="steelblue") +
    theme_bw() + 
    facet_wrap(~ sample, ncol=1)
  
  png_file = paste0(data_dir, 'allele_freqs_homozygote_stretches_', chrom, '.png')
  ggsave(plot, filename = png_file, width=16, height=9)
}




plot = ggplot(data_FJ2008, aes(x=pos, y=freq)) + 
  geom_point(aes(color = type),alpha=.50) +
  theme_bw() + 
  facet_wrap(~ chrom, scales = c('free_x'))
plot

data_FJ2008_chrom17 = data_FJ2008[grep("_17", data_FJ2008$chrom),]
plot = ggplot(data_FJ2008_chrom17, aes(x=pos, y=freq)) + 
  geom_point(aes(color = type),alpha=.50) +
  theme_bw() #+ 
  # facet_wrap(~ chrom, scales = c('free_x'))
plot


## plot allele frequencies in density plot per chromosome per sample

agg_data <- as.data.frame(table(freq_data$chrom, freq_data$sample, freq_data$gt))
colnames(agg_data) <- c("chrom", "sample", "gt", "count")
agg_data = agg_data[ ! grepl("SCAF", agg_data$chrom), ]

# Step 2: Calculate percentages
agg_data <- within(agg_data, {
  percentage <- ave(count, chrom, sample, FUN = function(x) x / sum(x) * 100)
})

# Step 3: Create the stacked barplot with ggplot
ggplot(agg_data, aes(x = chrom, y = percentage, fill = gt)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_wrap(~sample) +
  labs(x = "Chromosome", y = "Percentage", fill = "Genotype") +
  theme_minimal()


# Step 3: Create the stacked barplot with ggplot
ggplot(agg_data, aes(x = chrom, y = count)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_wrap(~sample) +
  labs(x = "Chromosome", y = "Percentage") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

## only plot the heterozygote SNPs
agg_data_hetero = agg_data[agg_data$gt == "0/1",]
ggplot(agg_data_hetero, aes(x = chrom, y = count, fill = gt)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_wrap(~sample, scales="free") +
  labs(x = "Chromosome", y = "count", fill = "Genotype") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

## only plot the heterozygote SNPs for JC20_08
agg_data_hetero_FJ2008 = agg_data_hetero[grep("FJ20_08", agg_data_hetero$sample),]
ggplot(agg_data_hetero_FJ2008, aes(x = chrom, y = count)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_wrap(~sample, scales="free") +
  labs(x = "Chromosome", y = "count") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

## extract all chromosomes 17 from the different samples, and show the 
## percentage of the heterozygote SNPs mapping to that chromosome, and 
## see whether this drops for chromosome 17
agg_data_hetero_chrom17 = agg_data_hetero[grep("_17", agg_data_hetero$chrom),]
sample_sums <- aggregate(count ~ sample, data = agg_data_hetero, sum)
agg_data_hetero_chrom17$total_sum = sample_sums[match(agg_data_hetero_chrom17$sample, sample_sums$sample),]$count
agg_data_hetero_chrom17$perc_chrom17 = 100*agg_data_hetero_chrom17$count/agg_data_hetero_chrom17$total_sum
ggplot(agg_data_hetero_chrom17, aes(x = sample, y = perc_chrom17)) +
  geom_bar(position = "stack", stat = "identity") +
  # facet_wrap(~sample, scales="free") +
  labs(x = "Sample", y = "Percentage of heterozygote SNPs in strain") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

## count the number of homozygote versus homozygote SNPs per sample
snp_homo_summary_data = as.data.frame(table(freq_data[freq_data$gt == '1/1',]$sample))
snp_hetero_summary_data = as.data.frame(table(freq_data[freq_data$gt == '0/1',]$sample))

snp_summary_data = cbind(snp_homo_summary_data, snp_hetero_summary_data[,2])
colnames(snp_summary_data) = c('strain', 'homo_snps', 'hetero_snps')
ggplot(snp_summary_data, aes(x=homo_snps, y=hetero_snps)) + 
  geom_point() +
  geom_text_repel(aes(label = strain), max.overlaps = 5) +
  labs(x = "Homozygous SNPs", y = "Heterozygous SNPs") +
  theme_minimal() + 
  coord_cartesian(xlim=c(0,160000))



