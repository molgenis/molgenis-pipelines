#MOLGENIS walltime=23:59:00 nodes=1 mem=4gb ppn=1

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string verifyBamIdDir
#string unifiedGenotyperDir
#string sortedBam
#string sortedBai
#string uniqueID
#string verifyBamIDVersion
#string stage
#string checkStage



getFile ${unifiedGenotyperDir}${uniqueID}.raw.vcf
getFile ${sortedBam}
getFile ${sortedBai}

#Load modules
${stage} verifyBamID/${verifyBamIDVersion}

#check modules
${checkStage}

mkdir -p ${verifyBamIdDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if verifyBamID \
  --vcf ${unifiedGenotyperDir}${uniqueID}.raw.vcf \
  --bam ${sortedBam} \
  --out ${verifyBamIdDir}${uniqueID}

then
 echo "returncode: $?"; putFile ${verifyBamIdDir}${uniqueID}.depthRG
 putFile ${verifyBamIdDir}${uniqueID}.depthSM
 putFile ${verifyBamIdDir}${uniqueID}.log
 putFile ${verifyBamIdDir}${uniqueID}.selfRG
 putFile ${verifyBamIdDir}${uniqueID}.selfSM
 echo "md5sums"
 md5sum ${verifyBamIdDir}${uniqueID}.depthRGM
 md5sum ${verifyBamIdDir}${uniqueID}.depthSM
 md5sum ${verifyBamIdDir}${uniqueID}.log
 md5sum ${verifyBamIdDir}${uniqueID}.selfRG
 md5sum ${verifyBamIdDir}${uniqueID}.selfSM
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
