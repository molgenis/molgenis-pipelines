library(stringr)
library(knitr)

path.output	= '~/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/first/out/' # update for your case
file.input	= '../example.Rmd'

setwd(path.output) # because figs need to be next to output

# Test parameter
r.parameter = "content_of_r.parameter"

#stop('TODO use compute pipeline to generate report based on variables!')

source('../csv_to_MDtable.R') # load helpers
# Get out/example.md file
knit(file.input)
