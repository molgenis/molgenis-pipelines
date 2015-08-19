#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string picardVersion
#string markDuplicatesBam
#string markDuplicatesBai
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta
#string toolDir


getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}

${stage} picard/${picardVersion}
${checkStage}


mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" ##  $0 Started "
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}picard/${picardVersion}/CollectRnaSeqMetrics.jar \
 INPUT=${markDuplicatesBam} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir} \
 
then
 echo "returncode: $?"; 
 cd collectRnaSeqMetricsDir
 putFile ${collectRnaSeqMetrics}
 putFile ${collectRnaSeqMetricsChart}
  md5sum $(basename ${collectRnaSeqMetrics}) > $(basename ${collectRnaSeqMetrics}).md5
 md5sum $(basename ${collectRnaSeqMetricsChart}) > $(basename ${collectRnaSeqMetricsChart}).md5
 echo "succes moving files";
 cd -
else
 echo "returncode: $?";
 echo "fail";
fi
echo "## "$(date)" ##  $0 Done "
