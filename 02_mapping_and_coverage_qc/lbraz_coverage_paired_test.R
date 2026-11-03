library(readxl)
library(dplyr)
library(effectsize)     # matched-pairs rank-biserial effect size

## ---- 0. Input -------------------------------------------------------------
path <- "/Users/pmonsieurs/programming/leishmania_susl/docs/lbraz_susl_swga/rebuttal2/DataSet1_braziliensis_revision_second_PM.xlsx"

## The sheet has a two-row header (a grouping row on top of the real header).
## skip = 1 makes the real header (row 2) the column names.
raw <- read_excel(path, sheet = "complete sample tracking", skip = 1)

dat <- raw %>%
  transmute(
    sample   = Name,
    method   = `Enrichment method`,
    protocol = Protocol,
    pct      = as.numeric(`percentage of the genome`),           # fraction 0-1
    paired   = `Paired statistical analysis (coverage)`
  ) %>%
  ## keep only the samples flagged for the paired test
  ## (the 14 matched L. braziliensis samples; CU-104, CU-030, CU-033 are "No")
  filter(tolower(paired) == "yes") %>%
  mutate(track = ifelse(method == "SuSL", "SuSL", protocol))     # SuSL / baits / digest

susl <- dat %>% filter(track == "SuSL") %>% select(sample, SuSL = pct)

## ---- 1. Continuous paired Wilcoxon signed-rank test ----------------------
## Genuine zeros are retained; no imputation is applied.
## Hodges-Lehmann estimate = median of the Walsh averages of the within-pair
## differences, as returned by wilcox.test(conf.int = TRUE).
run_wilcox <- function(prot) {
  sw <- dat %>% filter(track == prot) %>% select(sample, sWGA = pct)
  pr <- inner_join(susl, sw, by = "sample")        # the exact pairs
  x <- pr$SuSL; y <- pr$sWGA; d <- x - y

  wt <- wilcox.test(x, y, paired = TRUE, exact = TRUE, conf.int = TRUE)
  rb <- rank_biserial(x, y, paired = TRUE)

  data.frame(
    comparison  = paste0("SuSL vs sWGA-", prot),
    n           = nrow(pr),
    SuSL_higher = sum(d > 0),
    median_SuSL = round(median(x) * 100, 1),
    median_sWGA = round(median(y) * 100, 1),
    HL_shift_pp = round(unname(wt$estimate) * 100, 1),
    CI_low_pp   = round(wt$conf.int[1] * 100, 1),
    CI_high_pp  = round(wt$conf.int[2] * 100, 1),
    r_rankbis   = round(rb$r_rank_biserial, 2),
    p_value     = signif(wt$p.value, 3)
  )
}

## Note: with tied or zero differences, wilcox.test() may warn that it cannot
## compute an exact p-value and switches to the normal approximation. The
## values are otherwise unaffected.
wilcox_results <- bind_rows(run_wilcox("baits"), run_wilcox("digest"))
cat("\n== Continuous paired Wilcoxon signed-rank test ==\n")
print(wilcox_results, row.names = FALSE)

