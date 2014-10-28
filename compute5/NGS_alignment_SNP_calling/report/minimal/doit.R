library(knitr)

path.output	= '~/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/minimal/out/' # update for your case
file.input	= '../001-minimal.Rmd'

setwd(path.output) # because figs need to be next to output
knit(file.input)

