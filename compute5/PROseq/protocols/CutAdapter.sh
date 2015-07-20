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
#string sampleName
#string cutadaptFile

${stage} cutadapt/${cutadaptVersion}
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${cutadaptDir}
cutadapt -a AATGATACGGCGACCACCGAGATCTACACTCGTCGGCAGCGTCAGATGTG -a CAAGCAGAAGACGGCATACGAGATTCGCCTTAGTCTCGTGGGCTCGGAGATGT -a CAAGCAGAAGACGGCATACGAGATCTAGTACGGTCTCGTGGGCTCGGAGATGT -a CAAGCAGAAGACGGCATACGAGATGCTCAGGAGTCTCGTGGGCTCGGAGATGT -a CAAGCAGAAGACGGCATACGAGATAGGAGTCCGTCTCGTGGGCTCGGAGATGT reads1FqGz > ${cutadaptFile}

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
      echo "md5sums"
      echo "${cutadaptFile} - " md5sum ${cutadaptFile}
      echo "${cutadaptFile} - " md5sum ${cutadaptFile}
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
fi


echo "## "$(date)" ##  $0 Done "
