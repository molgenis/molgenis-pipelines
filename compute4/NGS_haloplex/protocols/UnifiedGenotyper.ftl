#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=46:00:00 mem=12 cores=5
#FOREACH externalSampleID

inputs "${mergedbam}" 
inputs "${indexfile}"
inputs "${dbsnprod}"
alloutputsexist \
 "${snpsvcf}" \
 "${snpsvcf}.metrics"


java -Xmx12g -Djava.io.tmpdir=${tempdir} -XX:+UseParallelGC -XX:ParallelGCThreads=1 -jar \
/target/gpfs2/gcc/tools/GenomeAnalysisTK-2.5-2-gf57256b/GenomeAnalysisTK.jar \
-T UnifiedGenotyper \
-R ${indexfile} \
-I ${mergedbam} \
-D ${dbsnpvcf} \
-ploidy ${ploidy} \
-stand_call_conf 50 \
--annotateNDA \
-dt NONE \
-o ${sample}.snps.vcf \
-nt 4 \
-L ${baitintervals}


putFile ${sample}.snps.vcf