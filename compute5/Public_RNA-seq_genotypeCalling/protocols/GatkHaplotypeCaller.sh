#MOLGENIS walltime=23:59:00 mem=10gb ppn=4

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir

#string gatkVersion
#string dbsnpVcf
#string dbsnpVcfIdx
#string onekgGenomeFasta
#list bsqrBam
#list bsqrBai

#string haplotyperDir
#string haplotyperVcf
#string haplotyperVcfIdx

echo "## "$(date)" ##  $0 Started "


for file in "${bsqrBam[@]}" "${bsqrBai[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

set -x
set -e

#${addOrReplaceGroupsBam} sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bsqrBam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${haplotyperDir}

#pseudo: java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R ref.fasta -I input.bam -recoverDanglingHeads -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -o output.vcf from http://gatkforums.broadinstitute.org/discussion/3891/calling-variants-in-rnaseq

java -Xmx10g -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${haplotyperDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T HaplotypeCaller \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf}\
 $inputs \
 -recoverDanglingHeads \
 -dontUseSoftClippedBases \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -o ${haplotyperVcf} \
 -nct 4

putFile ${haplotyperVcf}
putFile ${haplotyperVcfIdx}

echo "## "$(date)" ##  $0 Done "
