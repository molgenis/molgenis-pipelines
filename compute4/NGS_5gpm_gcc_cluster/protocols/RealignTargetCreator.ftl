
#MOLGENIS walltime=35:59:00 mem=10 cores=4

module load GATK/1.0.5069
module list

inputs "${dedupbam}" 
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${pilot1KgVcf}"
inputs "${baitsbed}"

alloutputsexist \
 "${realignTargets}"

java -Xmx10g -jar -Djava.io.tmpdir=${tempdir} \
$GATK_HOME/GenomeAnalysisTK.jar \
-l INFO \
-T RealignerTargetCreator \
-U ALLOW_UNINDEXED_BAM \
-I ${dedupbam} \
-L ${baitsbed} \
-R ${indexfile} \
-D ${dbsnprod} \
-B:indels,VCF ${pilot1KgVcf} \
-o ${realignTargets}
