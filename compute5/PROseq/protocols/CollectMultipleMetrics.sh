#MOLGENIS walltime=23:59:00 mem=4gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
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
#string toolDir
#getFile ${sortedBam}
#getFile ${sortedBai}
#getFile ${onekgGenomeFasta}


#load modules
${stage} picard/${picardVersion}

#Check modules
${checkStage}

mkdir -p ${collectMultipleMetricsDir}_QC

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

insertSizeMetrics=""
if [ ${#reads2FqGz} -ne 0 ]; then
	insertSizeMetrics="PROGRAM=CollectInsertSizeMetrics"
fi

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
if java -jar -Xmx4g -XX:ParallelGCThreads=4 ${toolDir}picard/${picardVersion}/CollectMultipleMetrics.jar \
 I=${sortedBam} \
 O=${collectMultipleMetricsPrefix} \
 R=${onekgGenomeFasta} \
 PROGRAM=CollectAlignmentSummaryMetrics \
 PROGRAM=QualityScoreDistribution \
 PROGRAM=MeanQualityByCycle \
 $insertSizeMetrics \
 TMP_DIR=${collectMultipleMetricsDir}
then
 echo "returncode: $?";
#putFile ${collectMultipleMetricsPrefix}.alignment_summary_metrics
# putFile ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics
# putFile ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf
# putFile ${collectMultipleMetricsPrefix}.quality_distribution_metrics
# putFile ${collectMultipleMetricsPrefix}.quality_distribution.pdf

 if [ ${#reads2FqGz} -ne 0 ]; then
   putFile ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf
   putFile ${collectMultipleMetricsPrefix}.insert_size_metrics
 fi
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi


echo "## "$(date)" ##  $0 Done "
