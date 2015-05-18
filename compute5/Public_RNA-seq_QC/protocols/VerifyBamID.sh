#MOLGENIS walltime=23:59:00 nodes=1 mem=4gb ppn=1

#string verifyBamIdDir
#string verifyBamIdToolDir
#string unifiedGenotyperDir
#string internalId
#string sampleName
#string sortedBam
#string uniqueID

set -u
set -e

function returnTest {
  return $1
}

getFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf
getFile ${sortedBai}

mkdir -p ${verifyBamIdDir}

echo "## "$(date)" Start $0"

${verifyBamIdToolDir}verifyBamID \
  --vcf ${unifiedGenotyperDir}${uniqueID}.raw.vcf \
  --bam ${sortedBam} \
  --out ${verifyBamIdDir}${uniqueID}

putFile ${verifyBamIdDir}${uniqueID}.depthRG
putFile ${verifyBamIdDir}${uniqueID}.depthSM
putFile ${verifyBamIdDir}${uniqueID}.log
putFile ${verifyBamIdDir}${uniqueID}.selfRG
putFile ${verifyBamIdDir}${uniqueID}.selfSM

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