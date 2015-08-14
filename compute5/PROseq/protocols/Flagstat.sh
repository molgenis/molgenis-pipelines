#MOLGENIS walltime=23:59:00 mem=1gb nodes=1 ppn=1

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string flagstatFile
#string markDuplicatesBam
#string samtoolsVersion
#string flagstatDir


echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

getFile ${markDuplicatesBam}

#load modules
${stage} SAMtools/${samtoolsVersion}
${checkStage}


#main ceate dir and run programmes

mkdir -p ${flagstatDir}
if samtools flagstat ${markDuplicatesBam} > ${flagstatFile}
then
 echo "returncode: $?"; 
 putFile  ${flagstatFile}
 cd ${flagstatDir}
md5sum $(basename ${flagstatFile}) > $(basename ${flagstatFile}).md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
