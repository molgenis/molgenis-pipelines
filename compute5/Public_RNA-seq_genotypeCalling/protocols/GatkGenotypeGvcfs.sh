#MOLGENIS walltime=10-23:59:00 mem=8gb ppn=16

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string dbsnpVcf
#string dbsnpVcfIdx

#string gatkVersion
#string haplotyperDir
#string onekgGenomeFasta
#list mergeGvcf

#string genotypedVcf
#string genotypedVcfIdx
#string toolDir

echo "## "$(date)" Start $0"

#for file in "${mergeGvcf[@]}" "${mergeGvcfIdx[@]}" "${onekgGenomeFasta}"; do
for file in "${mergeGvcf[@]}" "${onekgGenomeFasta}"; do
    echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}


# sort unique and print like ' --variant file1.vcf --variant file2.vcf '
gvcfs=($(printf '%s\n' "${mergeGvcf[@]}" | sort -u ))

inputs=$(printf ' --variant %s ' $(printf '%s\n' ${gvcfs[@]}))

mkdir -p ${haplotyperDir}

if java -Xmx4g -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${haplotyperDir} -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
 -T GenotypeGVCFs \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf}\
 -o ${genotypedVcf} \
 $inputs \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -nt 4

then
 echo "returncode: $?"; 
 
 putFile ${genotypedVcf}
 putFile ${genotypedVcfIdx}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
