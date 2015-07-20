#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=10:00:00

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
#string nTreads
#string platform
#string hisatAlignmentDir
#string hisatVersion
#string uniqueID
#string readQuality
#string samtoolsVersion

getFile ${reads1FqGz}
if [ ${#reads2FqGz} -eq 0 ]; then
   input="-U ${reads1FqGz}"
   echo "Single end alignment of ${reads1FqGz}"
else
   getFile ${reads2FqGz}
   input="-1 ${reads1FqGz} -2 ${reads2FqGz}"
   echo "Paired end alignment of ${reads1FqGz} and ${reads2FqGz}"
fi

#Load modules
${stage} hisat/${hisatVersion}
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

mkdir -p ${hisatAlignmentDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if hisat -x ${referenceGenomeHisat} \
  ${input}\
  -p ${nTreads} \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName} | \
  samtools view -h -b -q ${readQuality} - > ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
then
  >&2 echo "Reads where filtered with MQ < 1."
  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
  echo "md5sums"
  md5sum ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
