library(ggplot2)

coverage_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/coverage/depth.parsed.csv'

## read in data
cov_data = read.csv(coverage_file, header=FALSE)
colnames(cov_data) = c('sample', 'million_reads', 'count', 'fraction_covered')
head(cov_data)

## read in metadata 
meta_data_file = '/Users/pmonsieurs/programming/leishmania_susl/data/Lbraziliensis.direct_sequencing.xlsx'
meta_data = read.xlsx(meta_data_file, sheet = 'Lbraziliensis.direct_sequencing')
head(meta_data)

## merge coverage data and meta data
cov_data = cbind(cov_data, meta_data[match(cov_data$sample, meta_data$ID_code),])

## for SureSelect, ignore the protocol and put all to none
cov_data[cov_data$Type == "SuSL",]$protocol = "none"

cov_data_mix = cov_data[grep("Mix", cov_data$name_unified),]
cov_data_clinic = cov_data[- grep("Mix", cov_data$name_unified),]

## remove sample LFA-CU-104 as this is not L. braziliensis
cov_data_clinic = cov_data_clinic[cov_data_clinic$name_unified != "LFA-CU-104",]


# ggplot(data = cov_data_mix, aes(x=million_reads, y=fraction_covered)) 
ggplot(data = cov_data_clinic, aes(x=million_reads, y=fraction_covered)) + 
  geom_line(aes(color = Type, linetype = protocol)) + 
  theme_bw() + 
  facet_wrap( ~ name_unified)

