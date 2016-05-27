#!/usr/bin/Rscript

###QCPhasing 
### read  variables
args <- commandArgs(TRUE)
## Default setting when no arguments passed
if(length(args) < 1) {
  args <- c("--help")
}

## Help section
if("--help" %in% args) {
  cat("
      plots for qc phasing 
      Arguments:
      --arg1= qcOutfile 	- character, path to the phenotype file
      --arg2= outDir   		- character, path to the directory were the results are saved
      --help              	- print this text
 
      Example:
      ./qcPhasingPlots.R --arg1=qcOutfile \n\n")
 
  q(save="no")
}
### path to phenos
qcFile = args[1]
#qcFile = "/Users/raulaguirre/Dropbox/Raul/phasing/PhasingQC_Output.txt"
outDir= args[2]
#outDir ="/Users/raulaguirre/Dropbox/Raul/phasing/"

#### cehcking outDir
if(substr(outDir, nchar(outDir),nchar(outDir)) != "/") {
  outDir <- paste0(outDir,"/")
}
outDir <- paste0(outDir,"plotRes/")
dir.create(outDir)

require(ggplot2)
require(reshape)
#require(ggthemes)
res <- read.table(qcFile, sep= "\t", header=FALSE)
#res <- res[,-9]
colnames(res) <- c("sampleId","match","homo_un_match","swap","gte","gte_w_swap","gte_v_swap","no_matches")
res <- as.data.frame(res)
rownames(res) <- res[,1]
mRes <- melt(res)
errorTypes <- names(table(mRes$variable))

for(i in 1:length(errorTypes)){
	tMain <- paste0(errorTypes[i], " in ",nrow(res)," samples")
	tPlot <- ggplot(subset(mRes, variable == errorTypes[i]), aes(x= value))+
				geom_histogram(bins = 10)+
				ggtitle(tMain)
	plotFileName <- paste0(outDir, "dist_type", errorTypes[i], ".tiff")
	tiff(file=plotFileName, width = 1600, height = 1800, units = "px", res = 300, compression = "lzw")
  	print(tPlot)
  	dev.off()
}
