#MOLGENIS walltime=23:59:00 nodes=1 mem=10gb ppn=8

#string stage
#string checkStage
#string referenceGenome
#string sampleName
#string reads1FqGz
#string nTreads
#string internalId
#string platform
#string hisatAlignmentDir
#string hisatVersion
#string uniqueID

set -u
set -e

function returnTest {
  return $1
}

getFile ${reads1FqGz}

#Load modules
${stage} hisat/${hisatVersion}

#check modules
${checkStage}

mkdir -p ${hisatAlignmentDir}

echo "## "$(date)" Start $0"

hisat -x ${referenceGenome} \
  -S ${hisatAlignmentDir}${uniqueID}.sam \
  -U ${reads1FqGz} \
  -p $nTreads \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName}

putFile ${hisatAlignmentDir}${uniqueID}.sam

if returnTest \
  0;
then
  echo "returncode: $?";
  echo "succes moving files";
else
  echo "returncode: $?";
  echo "fail";
fi