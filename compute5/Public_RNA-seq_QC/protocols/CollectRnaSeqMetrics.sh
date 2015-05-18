#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir
#string picardVersion
#string sortedBam
#string sortedBai
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta

set -u
set -e

function returnTest {
  return $1
}

getFile ${sortedBam}
getFile ${sortedBai}

${stage} picard-tools/${picardVersion}
${checkStage}

mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" ##  $0 Started "

java -Xmx8g -XX:ParallelGCThreads=4 -jar $PICARD_HOME/CollectRnaSeqMetrics.jar \
 INPUT=${sortedBam} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir} \
 

putFile ${collectRnaSeqMetrics}
putFile ${collectRnaSeqMetricsChart}



echo "## "$(date)" ##  $0 Done "

if returnTest \
  0;
then
  echo "returncode: $?";
  echo "succes moving files";
else
  echo "returncode: $?";
  echo "fail";
fi
