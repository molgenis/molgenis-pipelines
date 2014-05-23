
#MOLGENIS walltime=23:59:00 mem=6 cores=4 nodes=1
#FOREACH externalSampleID

module load picard-tools/1.61
module list

inputs <#list sortedrecalbam as srb> "${srb}" </#list>
alloutputsexist "${mergedbam}" \
"${mergedbamindex}"

<#if sortedrecalbam?size == 1>
	ln -s ${sortedrecalbam[0]} ${mergedbam}
	ln -s ${sortedrecalbam[0]}.bai ${mergedbamindex}
<#else>
	java -jar -Xmx6g $PICARD_HOME/MergeSamFiles.jar \
	<#list sortedrecalbam as srb>INPUT=${srb} \
	</#list>
	ASSUME_SORTED=true USE_THREADING=true \
	TMP_DIR=${tempdir} MAX_RECORDS_IN_RAM=6000000 \
	OUTPUT=${mergedbam} \
	SORT_ORDER=coordinate \
	VALIDATION_STRINGENCY=SILENT
	
	java -jar -Xmx3g $PICARD_HOME/BuildBamIndex.jar \
	INPUT=${mergedbam} \
	OUTPUT=${mergedbamindex} \
	VALIDATION_STRINGENCY=LENIENT \
	MAX_RECORDS_IN_RAM=1000000 \
	TMP_DIR=${tempdir}
</#if>
