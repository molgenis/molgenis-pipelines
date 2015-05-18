#MOLGENIS walltime=23:59:00 nodes=1 mem=6gb ppn=4

#string stage
#string checkStage
#string sampleName
#string nTreads
#string internalId
#string platform
#string picardVersion
#string toolDir
#string hisatAlignmentDir
#string sortedBamDir
#string sortedBam
#string sortedBai
#string uniqueID
#string jdkVersion

set -u
set -e

function returnTest {
  return $1
}

getFile ${hisatAlignmentDir}${uniqueID}.sam

#Load modules
${stage} jdk/${jdkVersion}

#check modules
${checkStage}

mkdir -p ${sortedBamDir}

echo "## "$(date)" Start $0"

java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}picard-tools-${picardVersion}/SortSam.jar \
  INPUT=${hisatAlignmentDir}${uniqueID}.sam \
  OUTPUT=${sortedBam} \
  SO=coordinate \
  CREATE_INDEX=true

putFile ${sortedBam}
putFile ${sortedBai}


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