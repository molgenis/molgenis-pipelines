#MOLGENIS walltime=00:59:00 mem=2 cores=1

set -e
set -u

#string createPerSampleFinalReportPl
#string finalReportResultDir
#string run
#string worksheet

#
# Change permissions.
#
umask ${umask}

module load ngs-utils

export PERL5LIB=${EBROOTNGSMINUTILS}/
${createPerSampleFinalReportPl} \
-i ${arrayDir} \
-o ${finalReportResultDir} \
-r ${run} \
-s ${worksheet}
