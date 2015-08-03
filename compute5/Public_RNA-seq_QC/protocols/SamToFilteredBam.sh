#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string referenceGenomeHisat
#string reads1FqGz
#string reads2FqGz
#string platform
#string hisatAlignmentDir
#string uniqueID
#string readQuality
#string samtoolsVersion
#string filteredBamDir
#string unfilteredBamDir
#string filteredBam

getFile ${hisatAlignmentDir}${uniqueID}.sam

#Load modules
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${filteredBamDir}
mkdir -p ${unfilteredBamDir}

if sed '/NH:i:[^1]/d' ${hisatAlignmentDir}${uniqueID}.sam | samtools view -h -b - > ${filteredBam}
then
   samtools view -h -b ${hisatAlignmentDir}${uniqueID}.sam > ${unfilteredBamDir}${uniqueID}.bam
  >&2 echo "Reads with flag NH:i:[2+] where filtered out (only leaving `unique` mapping reads)."
  rm ${hisatAlignmentDir}${uniqueID}.sam
  echo "returncode: $?"; putFile ${filteredBam}
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
