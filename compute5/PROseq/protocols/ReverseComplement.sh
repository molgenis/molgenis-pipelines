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
#string reverseComplementDir
#string singleEndCutAdapt
#string singleEndRC


${stage} FASTX-Toolkit/${fastxVersion}
${checkStage}

echo "## "$(date)" ##  $0 Started "
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${reverseComplementDir}

#if [ ${#reads2FqGz} -eq 0 ];
#then
  echo 'single end'
  if fastx_reverse_complement -i ${singleEndCutAdapt} -o ${singleEndRC}
  then
      echo "returncode: $?";
      echo "succes moving files";
  else
      echo "returncode: $?";
      echo "fail";
  fi
#else
#  echo 'paired end'
#  if fastx_reverse_complement -i ${pairedEndCutAdapt1} -o ${pairedEndRC1} && fastx_reverse_complement -i ${pairedEndCutAdapt2} -o ${pairedEndRC2}
#  then
#    echo "returncode: $?";
#    echo "succes moving files";
#  else
#    echo "returncode: $?";
#    echo "fail";
#  fi
#fi

echo "## "$(date)" ##  $0 Done "