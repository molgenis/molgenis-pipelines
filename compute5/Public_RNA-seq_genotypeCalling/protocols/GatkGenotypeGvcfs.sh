#MOLGENIS walltime=71:59:00 mem=10gb ppn=8

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
#list mergeChrGvcf

#string genotypedChrVcf
#string genotypedChrVcfIdx
#string toolDir

echo "## "$(date)" Start $0"

#for file in "${mergeChrGvcf[@]}" "${mergeChrGvcfIdx[@]}" "${onekgGenomeFasta}"; do
for file in "${mergeChrGvcf[@]}" "${onekgGenomeFasta}"; do
    echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}


# sort unique and print like ' --variant file1.vcf --variant file2.vcf '
gvcfs=($(printf '%s\n' "${mergeChrGvcf[@]}" | sort -u ))

inputs=$(printf ' --variant %s ' $(printf '%s\n' ${gvcfs[@]}))

mkdir -p ${haplotyperDir}

if java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${haplotyperDir} -jar EBROOTGATK/GenomeAnalysisTK.jar \
 -T GenotypeGVCFs \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf} \
 -o ${genotypedChrVcf} \
 $inputs \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -nt 6

then
 echo "returncode: $?"; 
 
 putFile ${genotypedChrVcf}
 putFile ${genotypedChrVcfIdx}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
