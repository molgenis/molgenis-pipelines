#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=01:00:00 nodes=1 cores=1 mem=4
#FOREACH externalSampleID

inputs "${pindelOutputVcf}"
inputs "${ugindelsvcf}"
alloutputsexist \
"${indelsVcf}"

perl ${mergeSVspl} \
-pindelVCF ${pindelOutputVcf} \
-unifiedGenotyperVCF ${ugindelsvcf} \
-outputVCF ${indelsVcf}