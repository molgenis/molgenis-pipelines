#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=40:00:00
#FOREACH externalSampleID

inputs "${indelsfilteredbed}"
alloutputsexist "${indelsmaskbed}"

python ${makeIndelMaskpyton} \
${indelsfilteredbed} \
10 \
${indelsmaskbed}