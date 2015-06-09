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



getFile ${hisatAlignmentDir}${uniqueID}.sam

#Load modules
#${stage} jdk/${jdkVersion}

#check modules
${checkStage}

mkdir -p ${sortedBamDir}

echo "## "$(date)" Start $0"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}picard-tools-${picardVersion}/SortSam.jar \
  INPUT=${hisatAlignmentDir}${uniqueID}.sam \
  OUTPUT=${sortedBam} \
  SO=coordinate \
  CREATE_INDEX=true \
  TMP_DIR=${sortedBamDir}

then
 echo "returncode: $?"; putFile ${sortedBam}
 putFile ${sortedBai}

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

