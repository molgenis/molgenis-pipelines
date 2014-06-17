#MOLGENIS walltime=23:59:00 mem=4gb nodes=1 ppn=8


#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string collectMultipleMetricsJar
#string gcBiasMetricsJar
#string hsMetricsJar
#string bamIndexStatsJar
#string inputCollectBamMetricsBam
#string inputCollectBamMetricsBamIdx
#string indexFile
#string collectBamMetricsPrefix
#string tmpCollectBamMetricsPrefix
#string tempDir
#string baitIntervals
#string targetIntervals
#string capturingKit
#string seqType
#string intermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "collectMultipleMetricsJar: ${collectMultipleMetricsJar}"
echo "gcBiasMetricsJar: ${gcBiasMetricsJar}"
echo "hsMetricsJar: ${hsMetricsJar}"
echo "bamIndexStatsJar: ${bamIndexStatsJar}"
echo "inputCollectBamMetricsBam: ${inputCollectBamMetricsBam}"
echo "inputCollectBamMetricsBamIdx: ${inputCollectBamMetricsBamIdx}"
echo "indexFile: ${indexFile}"
echo "collectBamMetricsPrefix: ${collectBamMetricsPrefix}"
echo "tmpCollectBamMetricsPrefix: ${tmpCollectBamMetricsPrefix}"
echo "tempDir: ${tempDir}"
echo "baitIntervals: ${baitIntervals}"
echo "targetIntervals: ${targetIntervals}"
echo "capturingKit: ${capturingKit}"
echo "seqType: ${seqType}"
echo "intermediateDir: ${intermediateDir}"


sleep 10

#Check if output exists
alloutputsexist \
"${collectBamMetricsPrefix}.alignment_summary_metrics" \
"${collectBamMetricsPrefix}.quality_distribution_metrics" \
"${collectBamMetricsPrefix}.quality_distribution.pdf" \
"${collectBamMetricsPrefix}.quality_by_cycle_metrics" \
"${collectBamMetricsPrefix}.quality_by_cycle.pdf" \
"${collectBamMetricsPrefix}.gc_bias_metrics" \
"${collectBamMetricsPrefix}.gc_bias_metrics.pdf" \
"${collectBamMetricsPrefix}.hs_metrics" \
"${collectBamMetricsPrefix}.bam_index_stats"

#Get input files
getFile ${inputCollectBamMetricsBam}
getFile ${inputCollectBamMetricsBamIdx}
getFile ${indexFile}
getFile ${recreateInsertsizePdfR}
if [ ${capturingKit} != "None" ]
then
	getFile ${baitIntervals}
	getFile ${targetIntervals}
fi



#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}


#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
java -jar -Xmx4g $PICARD_HOME/${collectMultipleMetricsJar} \
I=${inputCollectBamMetricsBam} \
R=${indexFile} \
O=${tmpCollectBamMetricsPrefix} \
PROGRAM=CollectAlignmentSummaryMetrics \
PROGRAM=CollectInsertSizeMetrics \
PROGRAM=QualityScoreDistribution \
PROGRAM=MeanQualityByCycle \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode CollectBamMetrics: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nCollectBamMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.alignment_summary_metrics ${collectBamMetricsPrefix}.alignment_summary_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_distribution_metrics ${collectBamMetricsPrefix}.quality_distribution_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_distribution.pdf ${collectBamMetricsPrefix}.quality_distribution.pdf
    mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle_metrics ${collectBamMetricsPrefix}.quality_by_cycle_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle.pdf ${collectBamMetricsPrefix}.quality_by_cycle.pdf
    putFile "${collectBamMetricsPrefix}.alignment_summary_metrics"
    putFile "${collectBamMetricsPrefix}.quality_distribution_metrics"
    putFile "${collectBamMetricsPrefix}.quality_distribution.pdf"
    putFile "${collectBamMetricsPrefix}.quality_by_cycle_metrics"
    putFile "${collectBamMetricsPrefix}.quality_by_cycle.pdf"
    
else
    echo -e "\nFailed to move CollectBamMetrics results to ${intermediateDir}\n\n"
    exit -1
fi


#Run Picard GcBiasMetrics
java -jar -Xmx4g $PICARD_HOME/${gcBiasMetricsJar} \
R=${indexFile} \
I=${inputCollectBamMetricsBam} \
O=${tmpCollectBamMetricsPrefix}.gc_bias_metrics \
CHART=${tmpCollectBamMetricsPrefix}.gc_bias_metrics.pdf \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode GcBiasMetrics: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nGcBiasMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.gc_bias_metrics ${collectBamMetricsPrefix}.gc_bias_metrics
    mv ${tmpCollectBamMetricsPrefix}.gc_bias_metrics.pdf ${collectBamMetricsPrefix}.gc_bias_metrics.pdf
    putFile "${collectBamMetricsPrefix}.gc_bias_metrics"
    putFile "${collectBamMetricsPrefix}.gc_bias_metrics.pdf"
    
else
    echo -e "\nFailed to move GcBiasMetrics results to ${intermediateDir}\n\n"
    exit -1
fi


if [ ${capturingKit} != "None" ]
then
	java -jar -Xmx4g $PICARD_HOME/${hsMetricsJar} \
	INPUT=${inputCollectBamMetricsBam} \
	OUTPUT=${tmpCollectBamMetricsPrefix}.hs_metrics \
	BAIT_INTERVALS=${baitIntervals} \
	TARGET_INTERVALS=${targetIntervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempDir}

else
	echo "## net.sf.picard.metrics.StringHeader" > ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "#" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "## net.sf.picard.metrics.StringHeader" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "#" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "## METRICS CLASS net.sf.picard.analysis.directed.HsMetrics" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "BAIT_SET	GENOME_SIZE	BAIT_TERRITORY	TARGET_TERRITORY	BAIT_DESIGN_EFFICIENCY	TOTAL_READS	PF_READS	PF_UNIQUE_READS	PCT_PF_READS	PCT_PF_UQ_READS	PF_UQ_READS_ALIGNED	PCT_PF_UQ_READS_ALIGNED	PF_UQ_BASES_ALIGNED	ON_BAIT_BASES	NEAR_BAIT_BASES	OFF_BAIT_BASES	ON_TARGET_BASES	PCT_SELECTED_BASES	PCT_OFF_BAIT	ON_BAIT_VS_SELECTED	MEAN_BAIT_COVERAGE	MEAN_TARGET_COVERAGE	PCT_USABLE_BASES_ON_BAIT	PCT_USABLE_BASES_ON_TARGET	FOLD_ENRICHMENT	ZERO_CVG_TARGETS_PCT	FOLD_80_BASE_PENALTY	PCT_TARGET_BASES_2X	PCT_TARGET_BASES_10X	PCT_TARGET_BASES_20X	PCT_TARGET_BASES_30X	HS_LIBRARY_SIZE	HS_PENALTY_10X	HS_PENALTY_20X	HS_PENALTY_30X	AT_DROPOUT	GC_DROPOUT	SAMPLE	LIBRARY	READ_GROUP" >> ${tmpCollectBamMetricsPrefix}.hs_metrics
	echo "NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA" >> ${tmpCollectBamMetricsPrefix}.hs_metrics

fi

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode HsMetrics: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nHsMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.hs_metrics ${collectBamMetricsPrefix}.hs_metrics
    putFile "${collectBamMetricsPrefix}.hs_metrics"
    
else
    echo -e "\nFailed to move HsMetrics results to ${intermediateDir}\n\n"
    exit -1
fi


#Run Picard BamIndexStats
java -jar -Xmx4g $PICARD_HOME/${bamIndexStatsJar} \
INPUT=${inputCollectBamMetricsBam} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir} \
> ${tmpCollectBamMetricsPrefix}.bam_index_stats

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode BamIndexStats: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nBamIndexStats finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.bam_index_stats ${collectBamMetricsPrefix}.bam_index_stats
    putFile "${collectBamMetricsPrefix}.bam_index_stats"
    
else
    echo -e "\nFailed to move BamIndexStats results to ${intermediateDir}\n\n"
    exit -1
fi
