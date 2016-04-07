#MOLGENIS walltime=23:59:00 mem=6gb ppn=6


#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string picardVersion
#string collectMultipleMetricsJar
#string dedupBam
#string dedupBamIdx
#string indexFile
#string collectBamMetricsPrefix
#string tempDir
#string seqType
#string picardJar
#string	project
#string logsDir

#Load Picard module
${stage} ${picardVersion}


makeTmpDir ${collectBamMetricsPrefix}
tmpCollectBamMetricsPrefix=${MC_tmpFile}

#Run Picard CollectAlignmentSummaryMetrics, CollectInsertSizeMetrics, QualityScoreDistribution and MeanQualityByCycle
java -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${collectMultipleMetricsJar} \
I=${dedupBam} \
R=${indexFile} \
O=${tmpCollectBamMetricsPrefix} \
PROGRAM=CollectAlignmentSummaryMetrics \
PROGRAM=CollectInsertSizeMetrics \
PROGRAM=QualityScoreDistribution \
PROGRAM=MeanQualityByCycle \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir}

echo -e "\nCollectBamMetrics finished succesfull. Moving temp files to final.\n\n"
mv ${tmpCollectBamMetricsPrefix}.alignment_summary_metrics ${dedupBam}.alignment_summary_metrics
mv ${tmpCollectBamMetricsPrefix}.quality_distribution_metrics ${dedupBam}.quality_distribution_metrics
mv ${tmpCollectBamMetricsPrefix}.quality_distribution.pdf ${dedupBam}.quality_distribution.pdf
mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle_metrics ${dedupBam}.quality_by_cycle_metrics
mv ${tmpCollectBamMetricsPrefix}.quality_by_cycle.pdf ${dedupBam}.quality_by_cycle.pdf

#If paired-end data *.insert_size_metrics files also need to be moved
if [ "${seqType}" == "PE" ]
then
	echo -e "\nDetected paired-end data, moving all files.\n\n"
	mv ${tmpCollectBamMetricsPrefix}.insert_size_metrics ${dedupBam}.insert_size_metrics
    	mv ${tmpCollectBamMetricsPrefix}.insert_size_histogram.pdf ${dedupBam}.insert_size_histogram.pdf

else
    echo -e "\nDetected single read data, no *.insert_size_metrics files to be moved.\n\n"

fi
