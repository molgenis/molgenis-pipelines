#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=23:00:00 mem=10 cores=2
#FOREACH externalSampleID

inputs "${snpeffjar}"
inputs "${snpeffconfig}" 
inputs "${sample}.snps.filtered.vcf"
inputs "${mergedbam}"
inputs "${dbsnpvcf}"
inputs "${indexfile}"
<#if capturingKit != "None">inputs "${baitsbed}"</#if>
alloutputsexist "${snpeffsummaryhtml}" "${snpeffintermediate}" "${snpsfinalvcf}"

####Create snpEFF annotations on original input file####
java -Xmx10g -jar ${snpeffjar} \
eff \
-v \
-c ${snpeffconfig} \
-i vcf \
-o vcf \
GRCh37.64 \
-onlyCoding true \
-stats ${snpeffsummaryhtml} \
${sample}.snps.filtered.vcf \
> ${snpeffintermediate}

####Annotate SNPs with snpEff information####
java -jar -Xmx10g /target/gpfs2/gcc/tools/GenomeAnalysisTK-2.5-2-gf57256b/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R ${indexfile} \
-I ${mergedbam} \
--variant ${sample}.snps.filtered.vcf \
-D ${dbsnpvcf} \
--useAllAnnotations \
--snpEffFile ${snpeffintermediate} \
--excludeAnnotation MVLikelihoodRatio \
--excludeAnnotation TechnologyComposition \
-dt NONE \
-o ${snpsfinalvcf} \<#if capturingKit != "None">
-L ${baitsbed} \</#if>
-nt 2
