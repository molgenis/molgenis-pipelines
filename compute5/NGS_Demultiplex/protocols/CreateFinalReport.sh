#MOLGENIS walltime=00:59:00 mem=2gb cores=1
#string createPerSampleFinalReportPl
#string finalReportResultDir
#string run
#string arrayDir
#string sampleSheet
#string workDir
#string runPrefix
#string ngsUtilsVersion
module load ${ngsUtilsVersion}

${createPerSampleFinalReportPl} \
-i ${arrayDir} \
-o ${finalReportResultDir} \
-r ${run} \
-s ${sampleSheet}

### Pipeline is finished, write a finished file
touch ${workDir}/logs/${runPrefix}_Demultiplexing.finished

