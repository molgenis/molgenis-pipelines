#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string cutadaptVersion
#string WORKDIR
#string projectDir
#string cutadaptDir
#string reads1FqGz
#string reads2FqGz
#string singleEndCutAdapt
#string pairedEndCutAdapt1
#string pairedEndCutAdapt2
#string adapters

${stage} cutadapt/${cutadaptVersion}
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${cutadaptDir}
if [ ${#reads2FqGz} -eq 0 ]; then
	echo "## "$(date)" Single end cutadapt of ${reads1FqGz}"
    adaptInput=$(awk -F',' '$1 == "${sampleName}" {print $2 " " $3}' ${adapters})
  if cutadapt --minimum-length 20 -o ${singleEndCutAdapt} ${adaptInput} ${reads1FqGz};
    then
      cp ${adapters} ${cutadaptDir}
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
else
    adaptInput=$(awk -F',' '$1 == "${sampleName}" {print $2 " " $3 " " $4 " " $5}' ${adapters})
	echo "## "$(date)" Paired end cutadapt of ${reads1FqGz} and ${reads2FqGz}"
  if cutadapt ${adaptInput} --minimum-length 20 -o ${pairedEndCutAdapt1} -p ${pairedEndCutAdapt2} ${reads1FqGz} ${reads2FqGz}
    then
      cp ${adapters} ${cutadaptDir}
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
fi


echo "## "$(date)" ##  $0 Done "
