#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string repeatBedgraph
#string platform
#string sortedBam
#string uniqueID
#string bedtoolsVersion
#string maskedBamDir
#string maskedBam
#string maskedFq
#string toolDir
#string picardVersion
#string maskedBamSorted

#Load modules
${stage} BEDTools/${bedtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${maskedBamDir}

if bedtools intersect -abam ${sortedBam} -b ${repeatBedgraph} > ${maskedBam}
then
  echo "reads removed, sorting bam"
  java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}picard/${picardVersion}/SortSam.jar \
   INPUT=${maskedBam} \
   OUTPUT=${maskedBamSorted} \
   SO=coordinate \
   CREATE_INDEX=true \
   TMP_DIR=${maskedBamDir}
echo "sorted, making fq from unsorted bam..."
bedtools bamtofastq -i ${maskedBam} -fq ${maskedFq}


  echo "returncode: $?";
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
