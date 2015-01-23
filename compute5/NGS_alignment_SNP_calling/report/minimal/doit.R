library(knitr)

path.output	= '~/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/minimal/out/' # update for your case
file.input	= '../001-minimal.Rmd'

setwd(path.output) # because figs need to be next to output

# Get out/001-minimal.md file
knit(file.input)

# Get out/001-minimal.R file with R commands, including different levels of doc
#purl(file.input, documentation = 0L)
#purl(file.input, documentation = 1L)
#purl(file.input, documentation = 2L)