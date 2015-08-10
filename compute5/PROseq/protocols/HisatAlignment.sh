#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=03:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string referenceGenomeHisat
#string singleEndRRna
#string platform
#string hisatAlignmentDir
#string hisatVersion
#string uniqueID
#string samtoolsVersion

echo "single end only!"
input="-U ${singleEndRRna}"
echo "Single end alignment of ${singleEndRRna}"

#Load modules
${stage} hisat/${hisatVersion}

#check modules
${checkStage}

mkdir -p ${hisatAlignmentDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if hisat -x ${referenceGenomeHisat} \
  ${input}\
  -p 8\
  --rg-id ${internalId} \
  --rg PL:${platform} \
  --rg PU:${sampleName}_${internalId}_${internalId} \
  --rg LB:${sampleName}_${internalId} \
  --rg SM:${sampleName} \
  -S ${hisatAlignmentDir}${uniqueID}.sam
then
  echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}.sam
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
