#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

#string stage
#string checkStage
#string picardVersion
#string sortedBam
#string sortedBai
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta
#string toolDir
#string RVersion

getFile ${sortedBam}
getFile ${sortedBai}

${stage} picard/${picardVersion}
${stage} R/${RVersion}
${checkStage}

mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" ##  $0 Started "

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}picard/${picardVersion}/CollectRnaSeqMetrics.jar \
 INPUT=${sortedBam} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir}

then
 echo "returncode: $?";
 putFile ${collectRnaSeqMetrics}
 putFile ${collectRnaSeqMetricsChart}

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
