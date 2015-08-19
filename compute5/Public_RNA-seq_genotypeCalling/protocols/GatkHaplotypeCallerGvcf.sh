#MOLGENIS walltime=23:59:00 mem=12gb ppn=8

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string gatkVersion
#string dbsnpVcf
#string dbsnpVcfIdx
#string onekgGenomeFasta
#list indelRealignmentBam
#string haplotyperDir
#string haplotyperGvcf
#string haplotyperGvcfIdx
#string toolDir

echo "## "$(date)" Start $0"


for file in "${indelRealignmentBam[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
#for file in "${indelRealignmentBam[@]}" "${indelRealignmentBai[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${indelRealignmentBam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${haplotyperDir}

if java -Xmx12g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${haplotyperDir} -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
 -T HaplotypeCaller \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf}\
 $inputs \
 -dontUseSoftClippedBases \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -o ${haplotyperGvcf} \
 -variant_index_type LINEAR \
 -variant_index_parameter 128000 \
 --emitRefConfidence GVCF

then
 echo "returncode: $?"; 

 putFile ${haplotyperGvcf}
 putFile ${haplotyperGvcfIdx}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
