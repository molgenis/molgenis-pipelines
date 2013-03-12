#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=45:59:00 mem=12 cores=8
#FOREACH run

#Source GAF bash
. ${gafhome}/gaf.bashrc


perl ${gafscripts}/run_GERALD.pl \
-run ${run} \
-samplecsv ${McWorksheet}