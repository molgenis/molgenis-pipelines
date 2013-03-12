#
# =====================================================
# $Id$
# $URL: http://www.molgenis.org/svn/molgenis_apps/trunk/modules/compute/protocols/Recalibrate.ftl $
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy: mdijkstra $
# =====================================================
#

#MOLGENIS walltime=47:59:00 mem=2 cores=1
#FOREACH run

#Source GCC bash
. ${root}/gcc.bashrc

umask 0007



perl ${scriptdir}/create_per_sample_finalreport.pl \
-inputdir ${arraydir} \
-outputdir ${arraydir} \
-run ${run} \
-samplecsv ${McWorksheet}