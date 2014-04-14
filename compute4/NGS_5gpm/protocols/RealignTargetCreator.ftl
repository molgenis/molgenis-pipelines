
#MOLGENIS walltime=35:59:00 mem=10

module load GATK/${gatkVersion}
module list

inputs "${dedupbam}" 
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${pilot1KgVcf}"
inputs "${baitsbed}"

alloutputsexist \
 "${realignTargets}"

java -Xmx10g -jar -Djava.io.tmpdir=${tempdir} \
${genomeAnalysisTKjar} \
-l INFO \
-T RealignerTargetCreator \
-U ALLOW_UNINDEXED_BAM \
-I ${dedupbam} \
-L ${baitsbed} \
-R ${indexfile} \
-D ${dbsnprod} \
-B:indels,VCF ${pilot1KgVcf} \
-o ${realignTargets}