#MOLGENIS walltime=47:59:00 mem=14gb ppn=8

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
#string genomeBuild
#string resDir
#string referenceFastaName
#list bqsrBam
#string haplotyperDir
#string toolDir

echo "## "$(date)" Start $0"


for file in "${bqsrBam[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
#for file in "${bqsrBam[@]}" "${bqsrBai[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bqsrBam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${haplotyperDir}

#do variant calling for all 25 chromosomes seperate
#for this purpose haplotyperGvcf variable is split in ${haplotyperDir}${sampleName}.chr$CHR.g.vcf

for CHR in {1..25}
do
   echo "CHR $CHR"
   if java -Xmx12g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${haplotyperDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
       -T HaplotypeCaller \
       -R ${onekgGenomeFasta} \
       --dbsnp ${dbsnpVcf} \
       $inputs \
       -dontUseSoftClippedBases \
       -stand_call_conf 10.0 \
       -stand_emit_conf 20.0 \
       -o ${haplotyperDir}${sampleName}.chr$CHR.g.vcf \
       -L ${resDir}/${genomeBuild}/intervals/${referenceFastaName}.chr$CHR.interval_list \
       --emitRefConfidence GVCF;
  then
    echo "returncode: $?";
    #haplotyperGvcf is split into seperate variables now

    putFile ${haplotyperDir}${sampleName}.chr$CHR.g.vcf
    putFile ${haplotyperDir}${sampleName}.chr$CHR.g.vcf.idx
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
done


echo "## "$(date)" ##  $0 Done "
