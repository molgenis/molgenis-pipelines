#MOLGENIS walltime=23:59:00 mem=4gb nodes=1 ppn=4

#string stage
#string checkStage
#string picardVersion
#string RVersion
#string reads2FqGz
#string collectMultipleMetricsDir
#string collectMultipleMetricsPrefix
#string onekgGenomeFasta
#string sortedBam
#string sortedBai

set -u
set -e

function returnTest {
  return $1
}

getFile ${sortedBam}
getFile ${sortedBai}
getFile ${onekgGenomeFasta}


#load modules
${stage} picard-tools/${picardVersion}
${stage} R/${RVersion}
${checkStage}

#main ceate dir and run programmes

mkdir -p ${collectMultipleMetricsDir}

echo "## "$(date)" Start $0"

insertSizeMetrics=""
if [ ${#reads2FqGz} -ne 0 ]; then
	insertSizeMetrics="PROGRAM=CollectInsertSizeMetrics"
fi

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
java -jar -Xmx4g -XX:ParallelGCThreads=4 $PICARD_HOME/CollectMultipleMetrics.jar \
 I=${sortedBam} \
 O=${collectMultipleMetricsPrefix} \
 R=${onekgGenomeFasta} \
 PROGRAM=CollectAlignmentSummaryMetrics \
 PROGRAM=QualityScoreDistribution \
 PROGRAM=MeanQualityByCycle \
 $insertSizeMetrics \
 TMP_DIR=${collectMultipleMetricsDir}

#VALIDATION_STRINGENCY=LENIENT \

putFile ${collectMultipleMetricsPrefix}.alignment_summary_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf 
putFile ${collectMultipleMetricsPrefix}.quality_distribution_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_distribution.pdf

if [ ${#reads2FqGz} -ne 0 ]; then
  putFile ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf
  putFile ${collectMultipleMetricsPrefix}.insert_size_metrics
fi

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
