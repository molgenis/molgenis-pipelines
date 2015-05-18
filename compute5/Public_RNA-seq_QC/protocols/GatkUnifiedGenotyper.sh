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
#string tabixToolDir
#string rawVCF
#string uniqueID

set -u
set -e

function returnTest {
  return $1
}

getFile ${dbsnpVcf}
getFile ${onekgGenomeFasta}
for file in "${sortedBam[@]}"; do
  echo "getFile file='$file'"
  getFile $file
done

#Load modules
${stage} jdk/{jdk-version}
${stage} tabix/{tabix-version}

#check modules
${checkStage}

mkdir -p ${unifiedGenotyperDir}

echo "## "$(date)" Start $0"

#print like '-I=file1.bam -I=file2.bam '
inputs=$(printf ' -I %s ' $(printf '%s\n' ${sortedBam[@]}))

java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}GATK-${gatkVersion}/GenomeAnalysisTK.jar \
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
tabix bgzip -c ${unifiedGenotyperDir}${uniqueID}.raw.vcf > ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz
tabix -p vcf ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz

putFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz
putFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz.gz
putFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz.tbi
putFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz.idx

echo "## "$(date)" ##  $0 Done "

if returnTest \
0;
then
  echo "returncode: $?";
  echo "succes moving files";
else
  echo "returncode: $?";
  echo "fail";
fi