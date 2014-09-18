#MOLGENIS walltime=01:00:00 nodes=1 cores=1 mem=4
#FOREACH project

Samples to be included in merged VCF:
<#list arrayFile as af>
	<#if af?has_content>
	${externalSampleID[af_index]}
	</#if>
</#list>

##Copy inputs
<#list arrayFile as af>
	<#if af?has_content>
	getFile ${sample[af_index]}.genotypeArray.updated.header.vcf
	</#if>
</#list>

##Check if outputs exist
alloutputsexist "${genotypeArrayVCF}"

##Run GATK CombineVariants
java -jar ${genomeAnalysisTKjar1324} \
-T CombineVariants \
-R ${indexfile} \
<#list arrayFile as af><#if af?has_content>--variant ${sample[af_index]}.genotypeArray.updated.header.vcf </#if></#list>\
-o ${genotypeArrayVCF} \
-genotypeMergeOptions REQUIRE_UNIQUE

##Copy output
putFile "${genotypeArrayVCF}"