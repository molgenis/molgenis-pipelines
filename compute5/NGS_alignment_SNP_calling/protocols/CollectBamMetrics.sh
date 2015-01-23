#MOLGENIS walltime=23:59:00 mem=4gb ppn=4


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
#string tempDir
#string recreateInsertSizePdfR
#string baitIntervals
#string targetIntervals
#string RVersion
#string capturingKit
#string seqType
#string intermediateDir
#string tmpDataDir
#string project

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
echo "tempDir: ${tempDir}"
echo "recreateInsertSizePdfR: ${recreateInsertSizePdfR}"
echo "baitIntervals: ${baitIntervals}"
echo "targetIntervals: ${targetIntervals}"
echo "RVersion: ${RVersion}"
echo "capturingKit: ${capturingKit}"
echo "seqType: ${seqType}"
echo "intermediateDir: ${intermediateDir}"

#Load Picard module
${stage} picard-tools/${picardVersion}

#Load R module
${stage} R/${RVersion}
${checkStage}

makeTmpDir ${collectBamMetricsPrefix}
tmpCollectBamMetricsPrefix=${MC_tmpFile}

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

    echo -e "\nCollectBamMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.alignment_summary_metrics ${inputCollectBamMetricsBam}.alignment_summary_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_distribution_metrics ${inputCollectBamMetricsBam}.quality_distribution_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_distribution.pdf ${inputCollectBamMetricsBam}.quality_distribution.pdf
    mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle_metrics ${inputCollectBamMetricsBam}.quality_by_cycle_metrics
    mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle.pdf ${inputCollectBamMetricsBam}.quality_by_cycle.pdf
    
    #If paired-end data *.insert_size_metrics files also need to be moved
    if [ ${seqType} == "PE" ]
	then
	echo -e "\nDetected paired-end data, moving all files.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.insert_size_metrics ${inputCollectBamMetricsBam}.insert_size_metrics
    mv ${tmpCollectBamMetricsPrefix}.insert_size_histogram.pdf ${inputCollectBamMetricsBam}.insert_size_histogram.pdf
    
    else
    echo -e "\nDetected single read data, no *.insert_size_metrics files to be moved.\n\n"
    
    fi
    
#Run Picard GcBiasMetrics
java -XX:ParallelGCThreads=4 -jar -Xmx4g $PICARD_HOME/${gcBiasMetricsJar} \
R=${indexFile} \
I=${inputCollectBamMetricsBam} \
O=${tmpCollectBamMetricsPrefix}.gc_bias_metrics \
CHART=${tmpCollectBamMetricsPrefix}.gc_bias_metrics.pdf \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir}

    echo -e "\nGcBiasMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.gc_bias_metrics ${inputCollectBamMetricsBam}.gc_bias_metrics
    mv ${tmpCollectBamMetricsPrefix}.gc_bias_metrics.pdf ${inputCollectBamMetricsBam}.gc_bias_metrics.pdf

######IS THIS STILL NEEDED, IMPROVEMENTS/UPDATES TO BE DONE?#####
#Create nicer insertsize plots if seqType is PE
#if [ ${seqType} == "PE" ]
#then
	# Overwrite the PDFs that were just created by nicer onces:
	Rscript ${recreateInsertSizePdfR} \
	--insertSizeMetrics ${inputCollectBamMetricsBam}.insert_size_metrics \
	--pdf ${inputCollectBamMetricsBam}.insert_size_histogram.pdf

#else
	# Don't do insert size analysis because seqType != "PE"

#fi


#####THIS IF/ELSE CONSTRUCTION NEEDS TO BE REMOVED#####
#####THIS "FAKE" FILE SHOULDN'T BE NEEDED, PLEASE FIX IN NEXT PIPELINE VERSION#####

#Run Picard HsMetrics if capturingKit was used
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
echo -e "\nHsMetrics finished succesfull. Moving temp files to final.\n\n"
mv ${tmpCollectBamMetricsPrefix}.hs_metrics ${inputCollectBamMetricsBam}.hs_metrics

#Run Picard BamIndexStats
java -jar -Xmx4g $PICARD_HOME/${bamIndexStatsJar} \
INPUT=${inputCollectBamMetricsBam} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir} \
> ${tmpCollectBamMetricsPrefix}.bam_index_stats

    echo -e "\nBamIndexStats finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpCollectBamMetricsPrefix}.bam_index_stats ${inputCollectBamMetricsBam}.bam_index_stats
