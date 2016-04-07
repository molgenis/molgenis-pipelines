#MOLGENIS walltime=23:59:00 mem=6gb ppn=6


#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string picardVersion
#string hsMetricsJar
#string hsMetrics
#string dedupBam
#string dedupBamIdx
#string tempDir
#string recreateInsertSizePdfR
#string capturedIntervals
#string capturedExomeIntervals
#string capturingKit
#string picardJar
#string	project
#string logsDir

#Load Picard module
${stage} ${picardVersion}

makeTmpDir ${hsMetrics}
tmpHsMetrics=${MC_tmpFile}

#Run Picard HsMetrics if capturingKit was used
if [ "${capturingKit}" == "UMCG/wgs" ] || [ "${capturingKit}" == "None" ]
then
	java -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${hsMetricsJar} \
	INPUT=${dedupBam} \
	OUTPUT=${tmpHsMetrics} \
	BAIT_INTERVALS=${capturedExomeIntervals} \
	TARGET_INTERVALS=${capturedExomeIntervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempDir}
else
	java -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${hsMetricsJar} \
	INPUT=${dedupBam} \
	OUTPUT=${tmpHsMetrics} \
	BAIT_INTERVALS=${capturedIntervals} \
	TARGET_INTERVALS=${capturedIntervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempDir}
fi

mv ${tmpHsMetrics} ${hsMetrics}
echo "moved ${tmpHsMetrics} to ${hsMetrics}"

