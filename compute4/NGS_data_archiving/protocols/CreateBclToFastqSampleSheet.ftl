#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=00:00:10 mem=2 cores=1
#FOREACH run

#Source GAF bash
. ${gafhome}/gaf.bashrc

getFile ${McWorksheet}
alloutputsexist "${illuminaSampleSheet}"


perl ${createIlluminaSampleSheet} \
-i ${McWorksheet} \
-o ${illuminaSampleSheet} \
-r ${run}
