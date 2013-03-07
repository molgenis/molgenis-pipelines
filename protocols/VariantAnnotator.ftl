#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=45:00:00 mem=10
#FOREACH externalSampleID

inputs "${snpeffjar}"
inputs "${snpeffconfig}" 
inputs "${snpsgenomicannotatedvcf}"
inputs "${mergedbam}"
inputs "${dbsnpvcf}"
inputs "${indexfile}"
<#if capturingKit != "None">inputs "${baitsbed}"</#if>
alloutputsexist "${snpeffsummaryhtml}" "${snpeffintermediate}" "${snpsfinalvcf}"

####Create snpEFF annotations on original input file####
java -Xmx4g -jar ${snpeffjar} \
eff \
-v \
-c ${snpeffconfig} \
-i vcf \
-o vcf \
GRCh37.64 \
-onlyCoding true \
-stats ${snpeffsummaryhtml} \
${snpsgenomicannotatedvcf} \
> ${snpeffintermediate}

####Annotate SNPs with snpEff information####
java -jar -Xmx4g ${genomeAnalysisTKjar1411} \
-T VariantAnnotator \
--useAllAnnotations \
--excludeAnnotation MVLikelihoodRatio \
--excludeAnnotation TechnologyComposition \
-I ${mergedbam} \
--snpEffFile ${snpeffintermediate} \
-D ${dbsnpvcf} \
-R ${indexfile} \
--variant ${snpsgenomicannotatedvcf} \<#if capturingKit != "None">
-L ${baitsbed} \</#if>
-o ${snpsfinalvcf}