#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=35:59:00 mem=4

module load picard-tools/${picardVersion}

getFile ${sortedbam}
getFile ${indexfile}
<#if capturingKit != "None">
getFile ${baitintervals}
getFile ${targetintervals}
<#else>
</#if>

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

<#if capturingKit != "None">
	java -jar -Xmx4g ${hsmetricsjar} \
	INPUT=${sortedbam} \
	OUTPUT=${hsmetrics} \
	BAIT_INTERVALS=${baitintervals} \
	TARGET_INTERVALS=${targetintervals} \
	VALIDATION_STRINGENCY=LENIENT \
	TMP_DIR=${tempdir}
<#else>
	echo "## net.sf.picard.metrics.StringHeader" > ${hsmetrics}
	echo "#" >> ${hsmetrics}
	echo "## net.sf.picard.metrics.StringHeader" >> ${hsmetrics}
	echo "#" >> ${hsmetrics}
	echo "" >> ${hsmetrics}
	echo "## METRICS CLASS net.sf.picard.analysis.directed.HsMetrics" >> ${hsmetrics}
	echo "BAIT_SETCS CLASSGENOME_SIZE.sf.pBAIT_TERRITORY.dTARGET_TERRITORYs       BAIT_DESIGN_EFFICIENCY  TOTAL_READS     PF_READS	PF_UNIQUE_READS PCT_PF_READS    PCT_PF_UQ_READS	PF_UQ_READS_ALIGNED	PCT_PF_UQ_READS_ALIGNED	PF_UQ_BASES_ALIGNED	ON_BAIT_BASES	NEAR_BAIT_BASES	OFF_BAIT_BASES	ON_TARGET_BASES	PCT_SELECTED_BASES	PCT_OFF_BAIT	ON_BAIT_VS_SELECTED	MEAN_BAIT_COVERAGE	MEAN_TARGET_COVERAGE	PCT_USABLE_BASES_ON_BAIT	PCT_USABLE_BASES_ON_TARGET	FOLD_ENRICHMENT	ZERO_CVG_TARGETS_PCT	FOLD_80_BASE_PENALTY	PCT_TARGET_BASES_2X	PCT_TARGET_BASES_10X	PCT_TARGET_BASES_20X	PCT_TARGET_BASES_30X	HS_LIBRARY_SIZE	HS_PENALTY_1None    NA_PENALNA_20X	NA_PENALNA_30X	NA_DROPONA	NA_DROPONA	NAMPLE	NABRARY	NAAD_GRONA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA	NA" >> ${hsmetrics}
</#if>

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
