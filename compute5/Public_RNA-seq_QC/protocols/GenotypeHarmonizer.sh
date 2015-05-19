#MOLGENIS walltime=23:59:00 nodes=1 mem=6gb ppn=4

#string stage
#string checkStage
#string toolDir
#string sampleName
#string unifiedGenotyperDir
#string internalId
#string genotypeHarminzerOutput
#string genotypeHarmonizerDir
#string uniqueID
#string jdkVersion
#string GenotypeHarmonizerVersion

set -u
set -e

function returnTest {
  return $1
}

getFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz

#Load modules
${stage} jdk/${jdkVersion}

#check modules
${checkStage}

mkdir -p ${genotypeHarmonizerDir}

echo "## "$(date)" Start $0"

java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}GenotypeHarmonizer-${GenotypeHarmonizerVersion}/GenotypeHarmonizer.jar \
  -i ${unifiedGenotyperDir}${uniqueID}.raw.vcf.gz \
  -o ${genotypeHarminzerOutput} \
  -I VCF \
  -O PLINK_BED

putFile ${genotypeHarminzerOutput}.fam
putFile ${genotypeHarminzerOutput}.log
putFile ${genotypeHarminzerOutput}.bed
putFile ${genotypeHarminzerOutput}.bim

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