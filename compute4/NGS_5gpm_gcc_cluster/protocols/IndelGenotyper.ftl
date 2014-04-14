
#MOLGENIS walltime=33:00:00 nodes=1 cores=4 mem=8
#FOREACH externalSampleID

module load GATK/1.3-24-gc8b1c92
module list

inputs "${mergedbam}"
inputs "${indexfile}"
inputs "${dbsnpvcf}"
alloutputsexist \
"${ugindelsvcf}" \
"${ugindelsmetrics}"

java -Xmx8g -jar $GATK_HOME/GenomeAnalysisTK.jar \
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
