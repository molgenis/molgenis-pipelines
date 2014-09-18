#
# =========================================================================================
# Create folder structure, config files and generate scripts using MOLGENIS/compute
# for the GAF workflow for BCL to FastQ conversion using Illumina's bcl2fastq convertor.
# =========================================================================================
#


#MOLGENIS walltime=00:10:00
#
##
### parameters declaration.
##
#

#string umask
#string runJobsDir
#string runResultsDir
#string scriptsDir
#string McWorksheet
#string run
#string bcl2FastqWorkflowDir
#string computeVersion

echo "umask: ${umask}"
echo "runJobsDir: ${runJobsDir}"
echo "runResultsDir: ${runResultsDir}"
echo "scriptsDir: ${scriptsDir}"
echo "McWorksheet: ${McWorksheet}"
echo "run: ${run}"
echo "bcl2FastqWorkflowDir: ${bcl2FastqWorkflowDir}"
echo "computeVersion: ${computeVersion}"

#
# Initialize: resource usage requests + workflow control
#

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

#
# Setup environment for tools we need.
#
module load molgenis_compute5/${computeVersion}
module list

#
# Create run dirs.
#
mkdir -p ${runJobsDir}
mkdir -p ${runResultsDir}

#
# Create subset of samples for this project.
#
export PERL5LIB=${scriptsDir}/
${scriptsDir}/extract_samples_from_GAF_list.pl --i ${McWorksheet} --o ${runJobsDir}/${run}.csv --c run --q ${run}

echo "McWorksheet,parameters" > ${runJobsDir}/PathToWorksheet.csv 
echo "${runJobsDir}/${run}.csv,${runJobsDir}/${run}.csv" >> ${runJobsDir}/PathToWorksheet.csv

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#
molgenis_compute.sh \
-p ${MC_HOME}/workflows/Bcl2FastQ/parameters.csv \
-p ${runJobsDir}/PathToWorksheet.csv \
-w ${MC_HOME}/workflows/Bcl2FastQ/workflow.csv \
-rundir ${runJobsDir} \
-runid ${runid}
