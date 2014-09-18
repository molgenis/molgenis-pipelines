#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=00:59:00 mem=4
#FOREACH externalSampleID


inputs "${indexfile}"
inputs "${sample}.snps.vcf"


java -jar -Xmx4g /target/gpfs2/gcc/tools/GenomeAnalysisTK-2.5-2-gf57256b/GenomeAnalysisTK.jar \
-T VariantFiltration \
-R ${indexfile} \
--variant ${sample}.snps.vcf \
--filterExpression "QUAL > 50" \
--filterName "PASS" \
-dt NONE \
-o ${sample}.snps.filtered.vcf \
-L ${baitintervals}

putFile ${sample}.snps.filtered.vcf
