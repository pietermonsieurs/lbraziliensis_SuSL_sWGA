library(ggplot2)

count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/primer_counts.csv'
count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/Human.primer_counts.csv'

count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/primer_counts.updated.csv'
count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/Human.primer_counts.updated.csv'

count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/primer_counts.updated2.csv'
count_file = '/Users/pmonsieurs/programming/leishmania_susl/results/swga/Human.primer_counts.updated2.csv'


count_data = read.csv(count_file, header=FALSE)
colnames(count_data) = c('primer', 'org', 'author', 'count')
head(count_data)

## add counts per Mbp
count_data$count_per_mbp = NA

count_data[count_data$org != 'Human',]$count_per_mbp = count_data[count_data$org != 'Human',]$count / 33
count_data[count_data$org == 'Human',]$count_per_mbp = count_data[count_data$org == 'Human',]$count / 3000

head(count_data)
count_data = count_data[-which(count_data$author == "swga2"),]

# grouped boxplot
ggplot(count_data, aes(x=org, y=count_per_mbp, fill=author)) + 
# ggplot(count_data, aes(x=org, y=count, fill=author)) + 
  geom_boxplot(outlier.shape = NA) + 
  geom_point(aes(color=author), position=position_jitterdodge(0.10), pch=21, alpha=0.50) + 
  theme_bw() + 
  theme(axis.text = element_text(size = 20)) + 
  theme(axis.title = element_text(size = 20)) +
  theme(legend.text=element_text(size=20))


# geom_jitter(aes(color=author), alpha=0.20) + 
  

count_data_filtered = count_data[count_data$author %in% c("Pilling", "sWGA2_sets"),]
count_data_filtered[count_data_filtered$author == "sWGA2_sets",]$author = "sWGA2 - this study"
ggplot(count_data_filtered, aes(x=org, y=count_per_mbp, fill=author)) + 
  # ggplot(count_data, aes(x=org, y=count, fill=author)) + 
  geom_boxplot(outlier.shape = NA, alpha = .70) + 
  # geom_point(aes(color=author), position=position_jitterdodge(0.10), pch=21, alpha=0.90) + 
  geom_point(aes(color=author), position=position_jitterdodge(0.10), alpha=1.00) +
  theme_bw() + 
  theme(axis.text = element_text(size = 20)) + 
  theme(axis.title = element_text(size = 20)) +
  theme(legend.text=element_text(size=20))
