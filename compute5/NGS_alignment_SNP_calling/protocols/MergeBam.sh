#MOLGENIS walltime=23:59:00 mem=6 ppn=2

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string sortSamJar
#string inputBam
#string tmpSortedBam
#string tmpSortedBamIdx
#output sortedBam
#output sortedBamIdx
#string tempDir
#string intermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "sortSamJar: ${sortSamJar}"
echo "inputBam: ${inputBam}"
echo "tmpSortedBam: ${tmpSortedBam}"
echo "tmpSortedBamIdx: ${tmpSortedBamIdx}"
echo "sortedBam: ${sortedBam}"
echo "sortedBamIdx: ${sortedBamIdx}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"


#Check if output exists
alloutputsexist \
"${sortedBam}" \
"${sortedBamIdx}"

#Get aligned BAM file
getFile ${inputBam}

#Load Picard module
${stage} picard/${picardVersion}
${checkStage}



java -jar -Xmx6g $PICARD_HOME/${mergeSamFilesJar} \
INPUT=${srb} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
USE_THREADING=true \
TMP_DIR=${tempdir} \
MAX_RECORDS_IN_RAM=6000000 \
VALIDATION_STRINGENCY=LENIENT
OUTPUT=${mergedbam} \













#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=23:59:00 mem=6 cores=2
#FOREACH externalSampleID

module load picard-tools/${picardVersion}

inputs <#list sortedrecalbam as srb> "${srb}" </#list>
alloutputsexist "${mergedbam}" \
"${mergedbamindex}"

<#if sortedrecalbam?size == 1>
	#cp ${sortedrecalbam[0]} ${mergedbam}
	#cp ${sortedrecalbam[0]}.bai ${mergedbamindex}
	ln -s ${sortedrecalbam[0]} ${mergedbam}
	ln -s ${sortedrecalbam[0]}.bai ${mergedbamindex}
<#else>
	java -jar -Xmx6g ${mergesamfilesjar} \
	<#list sortedrecalbam as srb>INPUT=${srb} \
	</#list>
	ASSUME_SORTED=true USE_THREADING=true \
	TMP_DIR=${tempdir} MAX_RECORDS_IN_RAM=6000000 \
	OUTPUT=${mergedbam} \
	SORT_ORDER=coordinate \
	VALIDATION_STRINGENCY=SILENT
	
	java -jar -Xmx3g ${buildbamindexjar} \
	INPUT=${mergedbam} \
	OUTPUT=${mergedbamindex} \
	VALIDATION_STRINGENCY=LENIENT \
	MAX_RECORDS_IN_RAM=1000000 \
	TMP_DIR=${tempdir}
</#if>