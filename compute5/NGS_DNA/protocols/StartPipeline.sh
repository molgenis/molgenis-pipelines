#MOLGENIS walltime=01:59:00 mem=4gb

#string tmpName
#list sequencingStartDate
#list sequencer
#list run
#list flowcell
#string project
#string logsDir
#string projectJobsDir

echo -e ${project} > ${logsDir}/${sequencingStartDate[0]}_${sequencer[0]}_${run[0]}_${flowcell[0]}.project_${project}.txt
echo "pipeline started"
cd ${projectJobsDir}
sh submit.sh

touch ${logsDir}/${sequencingStartDate[0]}_${sequencer[0]}_${run[0]}_${flowcell[0]}.pipeline.started
