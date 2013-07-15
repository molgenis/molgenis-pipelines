#
# =================================================================================
# Create a per sample final report file (with results from a SNP array experiment).
# =================================================================================
#

#MOLGENIS walltime=00:59:00 mem=2 cores=1

#
##
### Parameter declaration
##
#

#string run
#string umask
#string scriptsDir
#string arrayDir
#string McWorksheet
#string createPerSampleFinalReportPl

#
# Initialize script specific vars.
#
RESULTDIR=${runResultsDir[0]}
SCRIPTNAME=${taskId}
FLUXDIR=${RESULTDIR}/${SCRIPTNAME}_in_flux/
fluxDir=${FLUXDIR}

#
# Should I stay or should I go?
#
if [ -f "${rundir}/${SCRIPTNAME}.sh.finished" ]
then
	# Skip this job script.
	echo "${rundir}/${SCRIPTNAME}.sh.finished already exists: skipping this job."
	exit 0
fi

#
# Change permissions.
#
umask ${umask}

export PERL5LIB=${scriptsDir}/
${createPerSampleFinalReportPl} \
-i ${arrayDir} \
-o ${arrayDir} \
-r ${run} \
-s ${McWorksheet}