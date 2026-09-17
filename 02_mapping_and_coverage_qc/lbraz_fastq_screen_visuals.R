library(ggplot2)
library(openxlsx)

meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
data_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_fastq_screen/'
data_file = paste0(data_dir, 'fastq_screen_summary.csv')

#### 1. Basic plot ####

plot_data = read.csv(data_file)
plot_data$sample = gsub("_R1", "", plot_data$sample)

org = 'Lbraziliensis'

plot_data = plot_data[plot_data$organism == org,]
plot_data = plot_data[plot_data$organism != 'Human',]

mapping_colors = c("01_unmapped_pc" = "lightgray", 
                   "05_one_hit_one_genome" = "lightskyblue1", 
                   "04_multiple_hits_one_genome" = "cornflowerblue",
                   "03_one_hit_multiple_genomes" = "darksalmon",
                   "02_multiple_hits_multiple_genomes" = "red")

## create as factor to revert the order of coord_flip
# plot_data$sample = as.factor(plot_data$sample)


# plot_data_scr = plot_data
# plot_data = plot_data[grep("Ldon", plot_data$organism),]

p = ggplot(plot_data, aes(x=sample,y=percentage,fill=type))
p = p + geom_bar(position="stack", stat="identity")
p = p + scale_fill_manual("legend", values = mapping_colors)
p = p + scale_x_discrete(limits=rev(levels(plot_data$sample))) ## change order to put sample 001 on top
p = p + coord_flip()
p = p + theme(text = element_text(size=12))
p = p + theme(legend.text=element_text(size=12))
p = p + ggtitle(paste0("FastQ screen -- ", org))
p


#### 2. get metadata and updated barplot ####

# ---- 2.1 add metadata to plot_data ---- 
# meta_data = read.xlsx(meta_data_file, sheet='bam')
meta_data = read.xlsx(meta_data_file, sheet='Lbraziliensis.direct_sequencing')
head(meta_data)
plot_data_full = cbind(plot_data, meta_data[match(plot_data$sample, meta_data$ID_code),])

## remove the category 03
plot_data_full = plot_data_full[-which(plot_data_full$type == "03_one_hit_multiple_genomes"),]


# ---- 2.2 for the artificial mixes ----
plot_data_sub = plot_data_full[plot_data_full$Type2 == 'Artificial sample',]
plot_data_sub$print_name = paste0(plot_data_sub$name_unified, " ", plot_data_sub$Type, "(", plot_data_sub$protocol, ")")
plot_data_sub$print_name2 = paste0(plot_data_sub$Type, " (", plot_data_sub$protocol, ")")

plot_data_sub

## exploring with two levels of X-axes
p = ggplot(plot_data_sub, aes(x=print_name,y=percentage,fill=type)) + 
  geom_bar(position="stack", stat="identity") + 
  scale_fill_manual("legend", values = mapping_colors) + 
  # scale_x_discrete(limits=rev(levels(plot_data_sub$sample))) + ## change order to put sample 001 on top
  #coord_flip() + 
  theme(text = element_text(size=12)) + 
  theme(legend.text=element_text(size=12),
        axis.text.x = element_text(angle = 90, vjust=1, hjust=1)) + 
  ggtitle(paste0("Percentage of L. braziliensis reads")) + 
  annotate(geom="text", x= 1.5 + 3*(0:3), y=-1, label = sort(unique(plot_data_sub$name_unified)))
p


## exploring facet wrap --> PREFERENCE
p = ggplot(plot_data_sub, aes(x=print_name2,y=percentage,fill=type)) + 
   geom_bar(position="stack", stat="identity") + 
   scale_fill_manual("legend", values = mapping_colors) + 
   # scale_x_discrete(limits=rev(levels(plot_data_sub$sample))) + ## change order to put sample 001 on top
   #coord_flip() + 
   theme(text = element_text(size=12)) + 
   theme(legend.text=element_text(size=12),
         axis.text.x = element_text(angle = 45, vjust=1, hjust=1),
         axis.title.x = element_blank()) + 
   ggtitle(paste0("Percentage of L. braziliensis reads")) + 
   facet_wrap(~ name_unified, nrow=1)
p




# ---- 2.3 for the clinical samples ----
plot_data_sub = plot_data_full[plot_data_full$Type2 == 'Clinical Sample',]

## create some additional columns. First remove the prefix of the clinical
## samples (LFA-CU). Then make combination of sample name + susl/swga + type
## of enrichmet. Next only susl/swga (Type) and enrichment protocol
plot_data_sub$name_unified_short = gsub("LFA-CU-", "", plot_data_sub$name_unified)
plot_data_sub$print_name = paste0(plot_data_sub$name_unified, " ", plot_data_sub$Type, "(", plot_data_sub$protocol, ")")
plot_data_sub$print_name2 = paste0(plot_data_sub$Type, " (", plot_data_sub$protocol, ")")

## remove the protocol for SuSL
plot_data_sub[grep("SuSL", plot_data_sub$print_name2),]$print_name2 = "SuSL"

plot_data_sub


## exploring facet wrap --> PREFERENCE
p = ggplot(plot_data_sub, aes(x=print_name2,y=percentage,fill=type)) + 
  geom_bar(position="stack", stat="identity",  width = 1) + 
  scale_fill_manual("legend", values = mapping_colors) + 
  theme_minimal() +
  theme(text = element_text(size=8), 
        # legend.text=element_text(size=12),
        axis.text.x = element_text(angle = 90, vjust=1, hjust=1),
        axis.title.x = element_blank()) + #,
        # strip.text = element_text(size = 8),
        # legend.text = element_text(size = 8),  
        # legend.title = element_text(size = 8)) + 
  ggtitle(paste0("Percentage of L. braziliensis reads")) + 
  facet_grid(. ~ name_unified_short, scales = "free_x", space = "free_x") 
p  

# initial_types = sort(unique(plot_data_sub$type))
new_types = c('01_unmapped_pc' = 'unmapped', 
              '02_multiple_hits_multiple_genomes' = 'map to Lb and human', 
              '04_multiple_hits_one_genome' = 'multiple hits Lb', 
              '05_one_hit_one_genome'= 'unique hit Lb')
# names(new_types) = initial_types
plot_data_sub$type_print <- ifelse(plot_data_sub$type %in% names(new_types), new_types[plot_data_sub$type], plot_data_sub$type)

mapping_colors = c('unmapped' = "lightgray", 
                   "unique hit Lb" = "lightskyblue1", 
                   "multiple hits Lb" = "cornflowerblue",
                   "03_one_hit_multiple_genomes" = "darksalmon",
                   "map to Lb and human" = "red")

names(mapping_colors)

plot_data_sub$type_print = as.factor(plot_data_sub$type_print)
plot_data_sub$type_print = factor(plot_data_sub$type_print, levels = rev(levels(plot_data_sub$type_print)))

## normal plot
p <- ggplot(plot_data_sub, aes(x = print_name2, y = percentage, fill = factor(type_print, levels = rev(levels(type_print))))) + 
  # geom_bar(position = position_dodge(), stat = "identity", width = 0.85) +
  geom_bar(position = position_stack(), stat = "identity", color = "white", width = .85, lwd=.01) +
  # scale_fill_manual("legend", values = mapping_colors, breaks = rev(levels(plot_data_sub$type_print))) + 
  scale_fill_manual("legend", values = mapping_colors) + 
  facet_grid(. ~ name_unified_short, scales = "free_x", space = "free_x") + 
  theme_minimal() +
  theme(text = element_text(size = 16), 
        axis.text.x = element_text(angle = 90, vjust = 1, hjust = 1),
        axis.title.x = element_blank(),
        legend.title = element_blank()) + 
  ggtitle(paste0("Percentage of L. braziliensis reads")) 
  
p


## plot with the axes shifted: 
p <- ggplot(
  plot_data_sub,
  aes(
    x = print_name2,
    y = percentage,
    fill = factor(type_print, levels = rev(levels(type_print)))
  )
) +
  geom_bar(
    stat = "identity",
    position = "stack",
    color = "white",
    width = 0.85,
    linewidth = 0.01
  ) +
  scale_fill_manual(values = mapping_colors) +
  facet_grid(
    name_unified_short ~ .,
    scales = "free_y",
    space = "free_y"
  ) +
  coord_flip() +
  theme_minimal() + xlab("") + 
  theme(
    strip.text.y = element_text(angle = 0),
    legend.title = element_blank()
  )

p

file_name = paste0(data_dir, 'FigureS2_fastq_screen_summary_clinical_samples_Lbraziliensis.png')
ggsave(p, file = file_name, width = 12, height = 8, dpi = 300)
