#MOLGENIS walltime=23:59:00 mem=6gb ppn=6


#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string hsMetricsJar
#string dedupBam
#string dedupBamIdx
#string collectBamMetricsPrefix
#string tempDir
#string recreateInsertSizePdfR
#string capturedIntervals
#string capturingKit
#string picardJar

#Load Picard module
${stage} ${picardVersion}

makeTmpDir ${collectBamMetricsPrefix}
tmpCollectBamMetricsPrefix=${MC_tmpFile}

#Run Picard HsMetrics if capturingKit was used
if [ "${capturingKit}" != "None" ]
then
	java -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${hsMetricsJar} \
	INPUT=${dedupBam} \
	OUTPUT=${tmpCollectBamMetricsPrefix}.hs_metrics \
	BAIT_INTERVALS=${capturedIntervals} \
	TARGET_INTERVALS=${capturedIntervals} \
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
mv ${tmpCollectBamMetricsPrefix}.hs_metrics ${dedupBam}.hs_metrics

