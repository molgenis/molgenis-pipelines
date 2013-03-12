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
inputs "${indelsVcf}"
inputs "${mergedbam}"
inputs "${dbsnpvcf}"
inputs "${indexfile}"
alloutputsexist \
"${indelsSummaryHtml}" \
"${indelsVcfIntermediate}" \
"${indelsFinalVcf}"

####Create snpEFF annotations on original input file####
java -Xmx4g -jar ${snpeffjar} \
eff \
-v \
-c ${snpeffconfig} \
-i vcf \
-o vcf \
GRCh37.64 \
-onlyCoding true \
-stats ${indelsSummaryHtml} \
${indelsVcf} \
> ${indelsVcfIntermediate}

####Annotate SNPs with snpEff information####
java -jar -Xmx4g ${genomeAnalysisTKjar1411} \
-T VariantAnnotator \
--useAllAnnotations \
--excludeAnnotation MVLikelihoodRatio \
--excludeAnnotation TechnologyComposition \
-I ${mergedbam} \
--snpEffFile ${indelsVcfIntermediate} \
-D ${dbsnpvcf} \
-R ${indexfile} \
--variant ${indelsVcf} \
-o ${indelsFinalVcf}