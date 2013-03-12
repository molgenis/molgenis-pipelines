#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=47:59:00 mem=2 cores=1
#FOREACH run

#Source GCC bash
. ${root}/gcc.bashrc

umask 0007

${gafscripts}/copy_fq_to_rawdatadir.pl \
-rawdatadir ${runResultsDir} \
-run ${run} \
-samplecsv ${McWorksheet}