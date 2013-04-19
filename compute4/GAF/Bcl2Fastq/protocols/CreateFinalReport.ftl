#
# =================================================================================
# Create a per sample final report file (with results from a SNP array experiment).
# =================================================================================
#

#MOLGENIS walltime=00:59:00 mem=2 cores=1
#FOREACH run

#
# Bash sanity.
#
set -e
set -u

#
# Change permissions.
#
umask ${umask}

perl ${createPerSampleFinalReportPl} \
-inputdir ${arrayDir} \
-outputdir ${arrayDir} \
-run ${run} \
-samplecsv ${McWorksheet}