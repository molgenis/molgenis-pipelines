#MOLGENIS nodes=1 ppn=10 mem=8gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage 
#string checkStage 
#string fastxVersion 
#string WORKDIR 
#string reads2FqGz
#string reads1FqGz

${stage} FASTX-Toolkit/${fastxVersion}
${checkStage}

echo "## "$(date)" ##  $0 Started "
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if [ ${#reads2FqGz} -eq 0 ];
then
  echo 'single end'
  if zcat ${reads1FqGz} | fastx_reverse_complement -o ${reads2FqGz%.gz}_reverse_complement.gz -z
  then
      echo "returncode: $?";
      echo "succes moving files";
  else
      echo "returncode: $?";
      echo "fail";
  fi
else
  echo 'paired end'
  if zcat ${reads2FqGz} | fastx_reverse_complement -o ${reads2FqGz$.gz}_reverse_complement.gz -z && \
     zcat ${reads1FqGz} | fastx_reverse_complement -o ${reads1FqGz%.gz}_reverse_complement.gz -z
  then
    echo "returncode: $?";
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
fi

echo "## "$(date)" ##  $0 Done "
