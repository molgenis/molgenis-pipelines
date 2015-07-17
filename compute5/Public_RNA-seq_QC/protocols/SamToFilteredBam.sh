#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=10:00:00

#string stage
#string checkStage
#string referenceGenomeHisat
#string sampleName
#string reads1FqGz
#string reads2FqGz
#string nTreads
#string internalId
#string platform
#string hisatAlignmentDir
#string hisatVersion
#string uniqueID
#string readQuality
#string samtoolsVersion

getFile ${hisatAlignmentDir}${uniqueID}.sam}

#Load modules
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"

if samtools view -h -b -q ${readQuality} ${hisatAlignmentDir}${uniqueID}.sam > ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
then
  >&2 echo "Reads where filtered with MQ < 1."
  rm ${hisatAlignmentDir}${uniqueID}.sam
  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
