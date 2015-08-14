#MOLGENIS walltime=8-23:59:59 mem=30gb ppn=8
################################^advised 45 gb for 300 files so 30 for 200 files?

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string onekgGenomeFasta
#string gatkVersion
#list haplotyperGvcf

#string haplotyperDir
#string mergeGvcf
#string mergeGvcfIdx
#string toolDir

echo "## "$(date)" Start $0"

for file in "${haplotyperGvcf[@]}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
gvcfs=($(printf '%s\n' "${haplotyperGvcf[@]}" | sort -u ))

inputs=$(printf ' --variant %s ' $(printf '%s\n' ${gvcfs[@]}))

mkdir -p ${haplotyperDir}

#pseudo: java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R ref.fasta -I input.bam -recoverDanglingHeads -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -o output.vcf from http://gatkforums.broadinstitute.org/discussion/3891/calling-variants-in-rnaseq

if java -Xmx30g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${haplotyperDir} -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
 -T CombineGVCFs \
 -R ${onekgGenomeFasta} \
 -o ${mergeGvcf} \
 $inputs 

then
 echo "returncode: $?"; 

 putFile ${mergeGvcf}
cd ${haplotyperDir}
md5sum $(basename ${mergeGvcf})> $(basename ${mergeGvcf})
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
