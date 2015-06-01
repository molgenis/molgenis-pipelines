#MOLGENIS walltime=23:59:00 nodes=1 mem=8gb ppn=4

#string stage
#string checkStage
#string onekgGenomeFasta
#string gatkVersion
#list sortedBam
#string sampleName
#string unifiedGenotyperDir
#string internalId
#string dbsnpVcf
#string toolDir
#string testIntervalList
#string rawVCF
#string uniqueID
#string jdkVersion
#string tabixVersion

set -u
set -e


getFile ${dbsnpVcf}
getFile ${onekgGenomeFasta}
for file in "${sortedBam[@]}"; do
  echo "getFile file='$file'"
  getFile $file
done

#Load modules
${stage} jdk/${jdkVersion}
${stage} tabix/${tabixVersion}

#check modules
${checkStage}

mkdir -p ${unifiedGenotyperDir}

echo "## "$(date)" Start $0"

#print like '-I=file1.bam -I=file2.bam '
inputs=$(printf ' -I %s ' $(printf '%s\n' ${sortedBam[@]}))

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}GATK-${gatkVersion}/GenomeAnalysisTK.jar \
  -R ${onekgGenomeFasta} \
  -T UnifiedGenotyper \
  $inputs \
  -L ${testIntervalList} \
  --dbsnp ${dbsnpVcf} \
  -o ${rawVCF} \
  -U ALLOW_N_CIGAR_READS \
  -rf ReassignMappingQuality \
  -DMQ 60

# have to gzip for GenomeHarnomizer use later
bgzip -c ${rawVCF} > ${rawVCF}.gz
tabix -p vcf ${rawVCF}.gz

then
 echo "returncode: $?"; 

 putFile ${rawVCF}
 putFile ${rawVCF}.gz
 putFile ${rawVCF}.gz.tbi
 putFile ${rawVCF}.gz.idx
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
