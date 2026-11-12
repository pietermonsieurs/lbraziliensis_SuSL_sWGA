library(ggplot2)
library(dplyr)


## input data
coverage_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/coverage/subsampling_summary.txt'
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'


## read in data. 
cov_data <- read.table(coverage_file,
                       header    = FALSE,
                       fill      = TRUE,
                       col.names = c("sample", "depth", "seed", "count"))
genome_size = 36*10^6
cov_data$perc_cov = cov_data$count/genome_size

meta_data = read.xlsx(meta_data_file, sheet = "stats_for_publication")
head(meta_data)
cov_data = cbind(cov_data, 
                 meta_data[match(cov_data$sample, meta_data$Sequencing.code), c("Name", "Enrichment.method", "Protocol")])
cov_data = cov_data[grep("LFA-CU-104", cov_data$Name, invert = TRUE),]
cov_data$perc_cov


## plot the data with facet_wrap per sample, showing the standard deviation 
## mean and SD across the 3 seeds, per sample × workflow × depth
cov_summary <- cov_data %>%
  group_by(Name, Enrichment.method, Protocol, depth) %>%
  summarise(mean_cov = mean(perc_cov, na.rm = TRUE),
            sd_cov   = sd(perc_cov,   na.rm = TRUE),
            .groups  = "drop")


cov_summary$Protocol[is.na(cov_summary$Protocol)] <- "none"
cov_summary$depth = cov_summary$depth / 1000000

cov_plot = ggplot(cov_summary, aes(x = depth, y = mean_cov,
                        colour   = Enrichment.method,
                        linetype = Protocol,
                        group    = interaction(Enrichment.method, Protocol))) +
  geom_line() +
  geom_point(size = 1.4) +
  geom_errorbar(aes(ymin = mean_cov - sd_cov, ymax = mean_cov + sd_cov),
                linetype = "solid") + 
  facet_wrap(~ Name) +
  labs(x = "Sequencing depth (million reads)", y = "Fraction of genome ≥5×",
       colour = "Enrichment", linetype = "Protocol") +
  scale_linetype_manual(values = c(none   = "solid",
                                     baits  = "dashed",
                                     digest = "dotted",
                                     ampure = "dotdash")) +
  theme_bw() + 
  scale_x_continuous(breaks = sort(unique(cov_summary$depth))) + 
  theme(axis.text.x = element_text(angle = 0, hjust = 1))

cov_plot

ggsave(cov_plot, 
       file = "/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/coverage/subsampling_summary.png",
       dpi = 300, 
       width = 12,
       height = 10)
