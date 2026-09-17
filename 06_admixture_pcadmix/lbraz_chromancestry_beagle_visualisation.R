
src_dir = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/per_chrom/'
viz_dir = paste0(src_dir, 'viz/')
chrom_file = '/Users/pmonsieurs/programming/leishmania_susl/results/lbraz_susl_swga/pcadmix/chroms.csv'
chroms = as.vector(read.table(chrom_file)$V1)

threshold = 0.80

for (chr in chroms) {
  # chr = 'LbrM.35_v4_pilon'
  # chr = 'LbrM.01_v4_pilon'
  
  
  ## read in the fbk values
  fbk <- read.table(paste0(src_dir, 'pcadmix.', chr, '.fbk.txt'))
  windows <- colnames(fbk)[-c(1,2)]
  samples <- unique(gsub('_A||_B', '', fbk$V1))
  # samples2 <- c(samples2[c(33,34)], samples2[-c(33,34)])
  
  samples_print = gsub("_none", "", samples)
  samples_print = gsub("_baits", "", samples_print)
  samples_print = gsub("_SuSL", "", samples_print)
  
  pdf(paste(viz_dir, chr, '.pdf', sep = ''), useDingbats = F)
  plot(1, type = 'n', xlim = c(1,length(windows)), ylim = c(1,(length(samples)*3)), axes = F, ylab = '', xlab = 'Index', main = chr)   
  axis(2, labels = gsub('A1', '', samples_print), at = seq(3,length(samples)*3,3), las = 1, cex.axis = .5)
  for (i in 1:length(samples)) {
    tmp <- matrix(ncol = length(windows), nrow = 2); colnames(tmp) <- windows
    
    tmp1 <- sapply(fbk[which(fbk$V1 %in% paste(samples[i], '_A', sep = '')), windows], function(x) which(x>threshold))
    if (is.list(tmp1)) tmp1 <- do.call(c,tmp1)
    tmp2 <- sapply(fbk[which(fbk$V1 %in% paste(samples[i], '_B', sep = '')), windows], function(x) which(x>threshold))
    if (is.list(tmp2)) tmp2 <- do.call(c,tmp2)
    tmp[1,names(tmp1)] <- as.numeric(tmp1)
    tmp[2,names(tmp2)] <- as.numeric(tmp2)
    rownames(tmp) <- c(paste(samples[i], '_A', sep = ''), paste(samples[i], '_B', sep = ''))
    
    anc.sub <- tmp
    anc.sub <- as.data.frame(t(anc.sub))
    anc.sub$xcoords <- 1:nrow(anc.sub)
    anc.sub$colsA <- anc.sub[,1]; anc.sub$colsB <- anc.sub[,2]
    anc.sub$colsA[which(anc.sub$colsA == 1)] <- "#00BA38"
    anc.sub$colsA[which(anc.sub$colsA == 2)] <- "#F8766D"
    anc.sub$colsA[which(anc.sub$colsA == 3)] <- "#619CFF"
    anc.sub$colsA[which(is.na(anc.sub$colsA))] <- 'gray90'
    anc.sub$colsB[which(anc.sub$colsB == 1)] <- "#00BA38"
    anc.sub$colsB[which(anc.sub$colsB == 2)] <- "#F8766D"
    anc.sub$colsB[which(anc.sub$colsB == 3)] <- "#619CFF"
    anc.sub$colsB[which(is.na(anc.sub$colsB))] <- 'gray90'
    rect(xleft = anc.sub$xcoords-.5, ybottom = i*3, xright = anc.sub$xcoords+.5, ytop = (i*3)+1, col = anc.sub$colsA, border = NA)
    rect(xleft = anc.sub$xcoords-.5, ybottom = i*3-1, xright = anc.sub$xcoords+.5, ytop = i*3, col = anc.sub$colsB, border = NA)
    abline(h=i*3, lwd = .5)
  }
  dev.off()
}

