
#MOLGENIS walltime=35:59:00 mem=4

module load picard-tools/${picardVersion}

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


java -jar -Xmx4g ${alignmentmetricsjar} \
I=${sortedbam} \
O=${alignmentmetrics} \
R=${indexfile} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

java -jar -Xmx4g ${gcbiasmetricsjar} \
R=${indexfile} \
I=${sortedbam} \
O=${gcbiasmetrics} \
CHART=${gcbiasmetricspdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

<#if seqType == "PE">
	java -jar -Xmx4g ${insertsizemetricsjar} \
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

java -jar -Xmx4g ${meanqualitybycyclejar} \
I=${sortedbam} \
O=${meanqualitybycycle} \
CHART=${meanqualitybycyclepdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

java -jar -Xmx4g ${qualityscoredistributionjar} \
I=${sortedbam} \
O=${qualityscoredistribution} \
CHART=${qualityscoredistributionpdf} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

	java -jar -Xmx4g ${hsmetricsjar} \
	INPUT=${sortedbam} \
	OUTPUT=${hsmetrics} \
	BAIT_INTERVALS=${baitintervals} \
	TARGET_INTERVALS=${targetintervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempdir}

java -jar -Xmx4g ${bamindexstatsjar} \
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
