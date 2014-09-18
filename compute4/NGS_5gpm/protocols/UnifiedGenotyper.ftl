
#MOLGENIS walltime=46:00:00 mem=8 cores=5
#FOREACH externalSampleID

module load GATK/${gatkVersion}
module list

inputs "${mergedbam}" 
inputs "${indexfile}"
inputs "${dbsnprod}"
alloutputsexist \
 "${snpsvcf}" \
 "${snpsvcf}.metrics"

java -Xmx8g -Djava.io.tmpdir=${tempdir} -XX:+UseParallelGC -XX:ParallelGCThreads=1 -jar \
${genomeAnalysisTKjar} \
-l INFO \
-T UnifiedGenotyper \
-I ${mergedbam} \
-L ${targetintervals} \
--out ${sample}.snps.vcf \
-R ${indexfile} \
-D ${dbsnprod} \
-stand_call_conf 30.0 \
-stand_emit_conf 10.0 \
-nt 4 \
--metrics_file ${sample}.snps.vcf.metrics