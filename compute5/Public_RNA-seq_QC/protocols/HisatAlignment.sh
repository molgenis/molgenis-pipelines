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
#string samtoolsVersion
#string readQuality
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

if hisat -x ${referenceGenomeHisat} \
  -S ${hisatAlignmentDir}${uniqueID}.sam \
  ${input}\
  -p ${nTreads} \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName}
then
  >&2 echo "Remove MQ<1 reads and convert .sam to .bam"
  samtools view -h -b -q ${readQuality} ${hisatAlignmentDir}${uniqueID}.sam > ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
  echo "remove .sam file"
  rm ${hisatAlignmentDir}${uniqueID}.sam
  echo "flagstat MQ filtered .bam file:"
  >&2 samtools flagstat ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam
  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.bam

  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
