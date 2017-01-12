#MOLGENIS nodes=1 ppn=8 mem=15gb walltime=16:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string referenceGenomeHisat2
#string reads1FqGz
#string reads2FqGz
#string platform
#string hisatAlignmentDir
#string hisat2Version
#string uniqueID
#string samtoolsVersion
#string rnaStrandness

if [ ${#reads2FqGz} -eq 0 ]; then
   input="-U ${reads1FqGz%.gz}_reverse_complement.gz"
   echo "Single end alignment of ${reads1FqGz%.gz}_reverse_complement.gz"
   if [[ ! -f ${reads1FqGz%.gz}_reverse_complement.gz ]] ; then
     echo "${reads1FqGz%.gz}_reverse_complement.gz does not exist"
     exit 1
   fi
   if [ "${rnaStrandness}" == "FR" ]; then
       rnaStrandness="F"
   elif [ "${rnaStrandness}" == "RF" ]; then
       rnaStrandness="R"
   fi
else
   input="-1 ${reads1FqGz%.gz}_reverse_complement.gz -2 ${reads2FqGz%.gz}_reverse_complement.gz"
   if [ "${rnaStrandness}" == "F" ]; then
       rnaStrandness="FR"
   elif [ "${rnaStrandness}" == "R" ]; then
       rnaStrandness="RF"
   fi
   echo "Paired end alignment of ${reads1FqGz%.gz}_reverse_complement.gz and ${reads2FqGz%.gz}_reverse_complement.gz"
   if [[ ! -f ${reads1FqGz%.gz}_reverse_complement.gz ]] ; then
      echo "${reads1FqGz%.gz}_reverse_complement.gz does not exist"
      exit 1
   fi
fi

#Load modules
${stage} hisat2/${hisat2Version}

#check modules
${checkStage}

mkdir -p ${hisatAlignmentDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
echo "Using RNA strandedness $rnaStrandness"
if [ "$rnaStrandness" == "unstranded" ]; then
    rnaStrandOption=""
else
    rnaStrandOption="--rna-strandness $rnaStrandness"
fi

if hisat2 -x ${referenceGenomeHisat2} \
  ${input} \
  -p 8 \
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName} \
  -S ${hisatAlignmentDir}${uniqueID}.sam $rnaStrandOption
then
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
