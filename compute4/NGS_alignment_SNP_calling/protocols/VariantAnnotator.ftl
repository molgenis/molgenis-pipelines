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

module load snpEff/2_0_5
module load GATK/1.4-11-g845c0b1
module list

inputs "${snpsgenomicannotatedvcf}"
inputs "${mergedbam}"
inputs "${dbsnpvcf}"
inputs "${indexfile}"
<#if capturingKit != "None">inputs "${baitsbed}"</#if>
alloutputsexist "${snpeffsummaryhtml}" "${snpeffintermediate}" "${snpsfinalvcf}"

####Create snpEFF annotations on original input file####
java -Xmx4g -jar $SNPEFF_HOME/snpEff.jar \
eff \
-v \
-c $SNPEFF_HOME/snpEff.config \
-i vcf \
-o vcf \
GRCh37.64 \
-onlyCoding true \
-stats ${snpeffsummaryhtml} \
${snpsgenomicannotatedvcf} \
> ${snpeffintermediate}

####Annotate SNPs with snpEff information####
java -jar -Xmx4g $GATK_HOME/GenomeAnalysisTK.jar \
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
