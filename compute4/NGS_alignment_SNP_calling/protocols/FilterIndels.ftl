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

inputs "${indelsbed}"
alloutputsexist "${indelsfilteredbed}"

perl ${filterSingleSampleCallsperl} \
--calls ${indelsbed} \
--max_cons_av_mm 3.0 \
--max_cons_nqs_av_mm 0.5 \
--mode ANNOTATE \
> ${indelsfilteredbed}