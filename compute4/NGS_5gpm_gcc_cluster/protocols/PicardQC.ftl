
#MOLGENIS walltime=35:59:00 mem=4 cores=6

module load picard-tools/1.61
module list


getFile ${sortedbam}
getFile ${indexfile}
getFile ${baitintervals}
getFile ${targetintervals}

alloutputsexist \
 "${alignmentmetrics}" \
 "${gcbiasmetrics}" \
 "${gcbiasmetricspdf}" \
 "${insertsizemetrics}" \
 "${insertsizemetricspdf}" \
 "${meanqualitybycycle}" \
 "${meanqualitybycyclepdf}" \
 "${qualityscoredistribution}" \
 "${qualityscoredistributionpdf}" \
 "${hsmetrics}" \
 "${bamindexstats}"


java -jar -Xmx4g $PICARD_HOME/CollectAlignmentSummaryMetrics.jar \
I=${sortedbam} \
O=${alignmentmetrics} \
R=${indexfile} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

java -jar -Xmx4g $PICARD_HOME/CollectGcBiasMetrics.jar \
R=${indexfile} \
I=${sortedbam} \
O=${gcbiasmetrics} \
CHART=${gcbiasmetricspdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

<#if seqType == "PE">
	java -jar -Xmx4g $PICARD_HOME/CollectInsertSizeMetrics.jar \
	I=${sortedbam} \
	O=${insertsizemetrics} \
	H=${insertsizemetricspdf} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempdir}
	
	# Overwrite the PDFs that were just created by nicer onces:
	${recreateinsertsizepdfR} \
	--insertSizeMetrics ${insertsizemetrics} \
	--pdf ${insertsizemetricspdf}
<#else>
	# Don't do insert size analysis because seqType != "PE" 
</#if>

java -jar -Xmx4g $PICARD_HOME/MeanQualityByCycle.jar \
I=${sortedbam} \
O=${meanqualitybycycle} \
CHART=${meanqualitybycyclepdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

java -jar -Xmx4g $PICARD_HOME/QualityScoreDistribution.jar \
I=${sortedbam} \
O=${qualityscoredistribution} \
CHART=${qualityscoredistributionpdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

	java -jar -Xmx4g $PICARD_HOME/CalculateHsMetrics.jar \
	INPUT=${sortedbam} \
	OUTPUT=${hsmetrics} \
	BAIT_INTERVALS=${baitintervals} \
	TARGET_INTERVALS=${targetintervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempdir}

java -jar -Xmx4g $PICARD_HOME/BamIndexStats.jar \
INPUT=${sortedbam} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir} \
> ${bamindexstats}


putFile ${alignmentmetrics}
putFile ${gcbiasmetrics}
putFile ${gcbiasmetricspdf}
putFile ${insertsizemetrics}
putFile ${insertsizemetricspdf}
putFile ${meanqualitybycycle}
putFile ${meanqualitybycyclepdf}
putFile ${qualityscoredistribution}
putFile ${qualityscoredistributionpdf}
putFile ${hsmetrics}
putFile ${bamindexstats}
