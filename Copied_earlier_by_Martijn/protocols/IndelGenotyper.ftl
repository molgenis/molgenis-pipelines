#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=33:00:00 nodes=1 cores=4 mem=8
#FOREACH externalSampleID

inputs "${mergedbam}"
inputs "${indexfile}"
inputs "${dbsnpvcf}"
alloutputsexist \
"${ugindelsvcf}" \
"${ugindelsmetrics}"

java -Xmx8g -jar ${genomeAnalysisTKjar1324} \
-T UnifiedGenotyper \
-R ${indexfile} \
-I ${mergedbam} \
-o ${ugindelsvcf} \
-metrics ${ugindelsmetrics} \
-D ${dbsnpvcf} \
--genotype_likelihoods_model INDEL \
--genotyping_mode DISCOVERY \
--output_mode EMIT_VARIANTS_ONLY \
-nt ${ugindelscores}
