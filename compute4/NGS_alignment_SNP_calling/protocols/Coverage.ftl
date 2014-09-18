#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=65:59:00 mem=12 cores=1
#FOREACH externalSampleID

module load R/2.14.2
module list

inputs "${mergedbam}"
alloutputsexist "${sample}.coverage.csv" \
"${samplecoverageplotpdf}" \
"${sample}.coverage.Rdata"


Rscript ${coveragescript} \
--bam ${mergedbam} \
--chromosome 1 \
--interval_list ${targetintervals} \
--csv ${sample}.coverage.csv \
--pdf ${samplecoverageplotpdf} \
--Rcovlist ${sample}.coverage.Rdata
