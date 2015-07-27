#MOLGENIS nodes=1 ppn=1 mem=5gb walltime=02:59:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string reads1FqGz
#string reads2FqGz
#string kallistoDir
#string kallistoVersion
#string uniqueID
#string kallistoIndex
#string fragmentLength

getFile ${reads1FqGz}

#Load modules
${stage} Kallisto/${kallistoVersion}

#check modules
${checkStage}
internalIdArray=(${internalId//_/ })

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
echo ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}
if [ ${#reads2FqGz} -eq 0 ]; then
  mkdir -p ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}
  echo "Single end kallisto of ${reads1FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength} \
    --single \
    -l 200 \
    ${reads1FqGz}
  then
    echo "returncode: $?"; putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/abundance.tsv
    putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/abundance.h5
    putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/run_info.json
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
else
  mkdir -p ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}
  getFile ${reads2FqGz}
  echo "Paired end kallisto of ${reads1FqGz} and ${reads2FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength} \
    ${reads1FqGz} ${reads2FqGz}
  then
    echo "returncode: $?"; putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/abundance.tsv
    putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/abundance.h5
    putFile ${kallistoDir}/${internalIdArray[1]}/${internalIdArray[2]}/${internalIdArray[3]}_${fragmentLength}/run_info.json
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
fi

echo "## "$(date)" ##  $0 Done "
