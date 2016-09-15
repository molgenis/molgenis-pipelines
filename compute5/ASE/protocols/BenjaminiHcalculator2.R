#!/usr/bin/Rscript
# gives BenhaminiH statistics from list of chisq values.
#
args <- commandArgs(TRUE)
FILE = args[1]
DF= as.numeric(args[2])
TOTALT= as.numeric(args[3])
FDR=as.numeric(args[4])
output= args[5]
eqtls <- read.table(FILE, sep='\t', header=F)
eqtls["corrected_pvalue"] <- (1-pchisq(eqtls$V11,DF) + 1e-16 ) * eqtls$V18 # * eqtls$V17
eqtls <- eqtls[with(eqtls, order(corrected_pvalue)), ]
for (i in 1:nrow(eqtls)){
  Q = (i/TOTALT)*FDR
  if (eqtls$corrected_pvalue[i] < Q){
    best <- i
  }
}
write.table(eqtls[1:best,], file=output, quote= F,  sep='\t', row.names = F, col.names = F)

