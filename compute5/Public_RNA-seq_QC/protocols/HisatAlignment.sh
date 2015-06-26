#MOLGENIS walltime=23:59:00 nodes=1 mem=10gb ppn=8

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
fastaFiles=${reads1FqGz}
if [ ${#reads2FqGz} -eq 0 ]; then
   input="-U ${reads1FqGz}"
   echo "Single end alignment ${fastaFiles}"
else
   getFile ${reads2FqGz}
   input="-1 ${reads1FqGz} -2 ${reads2FqGz}"
   echo "Paired end alignment of ${fastaFiles}"
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
  -p $nTreads \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName}

then
  samtools view -b -q 10 ${hisatAlignmentDir}${uniqueID}.sam > ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.sam

  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}.sam
  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}_qual_${readQuality}.sam

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
