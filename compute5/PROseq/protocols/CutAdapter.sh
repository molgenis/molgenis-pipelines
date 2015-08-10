#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string cutadaptVersion
#string projectDir
#string cutadaptDir
#string reads1FqGz
#string reads2FqGz
#string singleEndCutAdapt
#string pairedEndCutAdapt1
#string pairedEndCutAdapt2
#string adapters
#string gawkVersion
${stage} cutadapt/${cutadaptVersion}
${stage} gawk/${gawkVersion}

${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${cutadaptDir}
if [ ${#reads2FqGz} -eq 0 ]; then
	echo "## "$(date)" Single end cutadapt of ${reads1FqGz}"
    adaptInput=$(gawk -F',' '$1 == "${sampleName}" {print $2 " " $3}' ${adapters})
  if cutadapt --minimum-length 20 -o ${singleEndCutAdapt} ${adaptInput} ${reads1FqGz};
    then
      echo "Correcting line length..."
      gawk '/length=[0-9]+/ && getline nline > 0{sub(/length=[0-9]+/, "length=" length(nline)); print $0 ORS nline; next} 1' ${singleEndCutAdapt} > ${singleEndCutAdapt}.tmp && mv ${singleEndCutAdapt}.tmp ${singleEndCutAdapt}
      echo "Finished"
      cp ${adapters} ${cutadaptDir}
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
else
    adaptInput=$(gawk -F',' '$1 == "${sampleName}" {print $2 " " $3 " " $4 " " $5}' ${adapters})
	echo "## "$(date)" Paired end cutadapt of ${reads1FqGz} and ${reads2FqGz}"
  if cutadapt ${adaptInput} --minimum-length 20 -o ${pairedEndCutAdapt1} -p ${pairedEndCutAdapt2} ${reads1FqGz} ${reads2FqGz}
    then
      echo "Correcting line length..."
      gawk '/length=[0-9]+/ && getline nline > 0{sub(/length=[0-9]+/, "length=" length(nline)); print $0 ORS nline; next} 1' ${pairedEndCutAdapt1} $ > ${pairedEndCutAdapt1}.tmp && mv ${pairedEndCutAdapt1}.tmp ${pairedEndCutAdapt1}
    
      {pairedEndCutAdapt2}
      echo "Finished"
      cp ${adapters} ${cutadaptDir}
      echo "returncode: $?";
    else
      echo "returncode: $?";
      echo "fail";
    fi
fi


echo "## "$(date)" ##  $0 Done "
