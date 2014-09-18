#
# =================================================================================
# Create a per sample final report file (with results from a SNP array experiment).
# =================================================================================
#

#MOLGENIS walltime=00:59:00 mem=2 cores=1
#FOREACH sequencingStartDate, sequencer, run, flowcell

#
# Bash sanity.
#
set -e
set -u

#
# Change permissions.
#
umask ${umask}

export PERL5LIB=${scriptsDir}/
${createPerSampleFinalReportPl} \
-i ${arrayDir} \
-o ${finalReportResultDir} \
-r ${run} \
-s ${McWorksheet}