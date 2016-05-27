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


#string genotypedChrVcf
#string genotypedChrVcfIdx
#string chromosome
#string toolDir
#string sampleName

echo "## "$(date)" Start $0"

#Generate input files, according to number of batches
for i in {0..2}
do
	echo "getFile file=${haplotyperDir}${sampleName}.chr${chromosome}.g.vcf.gz"
	inputs+=" --variant ${haplotyperDir}${sampleName}.chr${chromosome}.g.vcf.gz"
done

#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${haplotyperDir}

if java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
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
 cd ${haplotyperDir}
 md5sum $(basename ${genotypedChrVcf})> $(basename ${genotypedChrVcf}).md5sum
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
