#MOLGENIS walltime=23:59:00 mem=30gb ppn=2
################################^advised 45 gb for 300 files so 30 for 200 files?
#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir
#string onekgGenomeFasta
#string gatkVersion
#list haplotyperGvcf
#list haplotyperGvcfIdx

#string haplotyperDir
#string mergeGvcf
#string mergeGvcfIdx

echo "## "$(date)" ##  $0 Started "



for file in "${haplotyperGvcf[@]}" "${haplotyperGvcfIdx[@]}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

set -x
set -e

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
gvcfs=($(printf '%s\n' "${haplotyperGvcf[@]}" | sort -u ))

inputs=$(printf ' --variant %s ' $(printf '%s\n' ${gvcfs[@]}))

mkdir -p ${haplotyperDir}

#pseudo: java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R ref.fasta -I input.bam -recoverDanglingHeads -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -o output.vcf from http://gatkforums.broadinstitute.org/discussion/3891/calling-variants-in-rnaseq

java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${haplotyperDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T CombineGVCFs \
 -R ${onekgGenomeFasta} \
 -o ${mergeGvcf} \
 $inputs 


putFile ${mergeGvcf}
putFile ${mergeGvcf}

echo "## "$(date)" ##  $0 Done "
