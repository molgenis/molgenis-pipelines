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

getFile ${hisatAlignmentDir}${uniqueID}.sam

#Load modules
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${filteredBamDir}
mkdir -p ${unfilteredBamDir}

if samtools view -h -b -q ${readQuality} ${hisatAlignmentDir}${uniqueID}.sam > ${filteredBamDir}${uniqueID}_qual_${readQuality}.bam
then
   samtools view -h -b ${hisatAlignmentDir}${uniqueID}.sam > ${unfilteredBamDir}${uniqueID}_qual_${readQuality}.bam
  >&2 echo "Reads where filtered with MQ < 1."
  rm ${hisatAlignmentDir}${uniqueID}.sam
  echo "returncode: $?"; putFile ${filteredBamDir}${uniqueID}_qual_${readQuality}.bam
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
