#MOLGENIS walltime=23:59:00 nodes=1 mem=6gb ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string nTreads
#string platform
#string picardVersion
#string toolDir
#string filteredBamDir
#string sortedBamDir
#string sortedBam
#string sortedBai
#string uniqueID
#string jdkVersion
#string readQuality
#string filteredBam

getFile ${filteredBamDir}${uniqueID}_qual_${readQuality}.bam

#Load modules
${stage} picard/${picardVersion}

#check modules
${checkStage}

mkdir -p ${sortedBamDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}picard/${picardVersion}/SortSam.jar \
  INPUT=${filteredBam} \
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

