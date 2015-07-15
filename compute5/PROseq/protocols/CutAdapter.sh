#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=10:00:00

#string stage
#string checkStage
#string cutadaptVersion
#string WORKDIR
#string projectDir
#string cutadaptDir
#string reads1FqGz
#string reads2FqGz
#string sampleName

${stage} cutadapt/${cutadaptVersion}
${checkStage}

echo "## "$(date)" Start $0"
mkdir -p ${cutadaptDir}
cutadapt reads1FqGz <command>

if [ ${#reads2FqGz} -eq 0 ]; then
	echo "## "$(date)" Single end cutadapt of ${reads1FqGz}"
    then
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
else
	echo "## "$(date)" Paired end cutadapt of ${reads1FqGz} and ${reads2FqGz}"
	
    then
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
fi


echo "## "$(date)" ##  $0 Done "
