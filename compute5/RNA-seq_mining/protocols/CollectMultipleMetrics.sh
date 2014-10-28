#MOLGENIS walltime=23:59:00 mem=4gb

#string stage
#string checkStage
#string picardVersion
#string RVersion
#string reads2FqGz
#string collectMultipleMetricsDir
#string collectMultipleMetricsPrefix
#string onekgGenomeFasta
#string markDuplicatesBam
#string markDuplicatesBai

#alloutputsext
alloutputsexist \
 ${collectMultipleMetricsPrefix}.alignment_summary_metrics \
 ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics \
 ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf \
 ${collectMultipleMetricsPrefix}.quality_distribution_metrics \
 ${collectMultipleMetricsPrefix}.quality_distribution.pdf 
# ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf \
# ${collectMultipleMetricsPrefix}.insert_size_metrics 
#

echo "## "$(date)" Start $0"

#echo  ${collectMultipleMetricsPrefix} 

getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}
getFile ${onekgGenomeFasta}


#load modules
${stage} picard-tools/${picardVersion}
${stage} R/${RVersion}
${checkStage}

#main ceate dir and run programmes

mkdir -p ${collectMultipleMetricsDir}

insertSizeMetrics=""
if [ ${#reads2FqGz} -ne 0 ]; then
	insertSizeMetrics="PROGRAM=CollectInsertSizeMetrics"
fi

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
java -jar -Xmx4g $PICARD_HOME/CollectMultipleMetrics.jar \
 I=${markDuplicatesBam} \
 O=${collectMultipleMetricsPrefix} \
 R=${onekgGenomeFasta} \
 PROGRAM=CollectAlignmentSummaryMetrics \
 PROGRAM=QualityScoreDistribution \
 PROGRAM=MeanQualityByCycle \
 $insertSizeMetrics \
 TMP_DIR=${collectMultipleMetricsDir}

#VALIDATION_STRINGENCY=LENIENT \

putFile  ${collectMultipleMetricsPrefix}.alignment_summary_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_by_cycle_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_by_cycle.pdf 
putFile ${collectMultipleMetricsPrefix}.quality_distribution_metrics 
putFile ${collectMultipleMetricsPrefix}.quality_distribution.pdf

if [ ${#reads2FqGz} -ne 0 ]; then
	putFile ${collectMultipleMetricsPrefix}.insert_size_histogram.pdf
	putFile ${collectMultipleMetricsPrefix}.insert_size_metrics 
fi

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
