library('ggplot2')

src_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/admixture/'
cv_file = paste0(src_dir, 'lbraz_admixture_CV_values_all_seeds.txt')
cv_data = read.table(cv_file, header=TRUE)
head(cv_data)

## remove the word "phylo" in the dataset value
cv_data$data_set = gsub("phylo.", "", cv_data$data_set)

cv_summary <- aggregate(CV_error ~ data_set + K_value,
                        data = cv_data,
                        FUN = function(x) c(mean = mean(x),
                                            se = sd(x)/sqrt(length(x))))


cv_summary <- do.call(data.frame, cv_summary)
colnames(cv_summary) <- c("sample_type", "K_value", "mean", "se")

# Plot
ggplot(cv_summary, aes(x = K_value, y = mean)) +
  geom_line(size = .5) +
  geom_point(size = 1) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.2) +
  labs(x = "K", y = "Mean CV error") +
  theme_minimal(base_size = 16) +
  # theme(
  #  panel.grid.minor = element_blank(),
  #  panel.grid.major.x = element_blank()
  # )  + 
  facet_wrap(~ sample_type) 



