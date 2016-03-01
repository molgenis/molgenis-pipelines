#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=01:00:00

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

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if [ ${#reads2FqGz} -eq 0 ]; then
  mkdir -p ${kallistoDir}/${uniqueID}_${fragmentLength}
  echo "Single end kallisto of ${reads1FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/${uniqueID}_${fragmentLength} \
    --single \
    -l ${fragmentLength} \
    ${reads1FqGz}
  then
    echo "returncode: $?"; putFile ${kallistoDir}/${uniqueID}_${fragmentLength}/abundance.tsv
    putFile ${kallistoDir}/${uniqueID}_${fragmentLength}/abundance.h5
    putFile ${kallistoDir}/${uniqueID}_${fragmentLength}/run_info.json
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
else
  mkdir -p ${kallistoDir}/${uniqueID}
  getFile ${reads2FqGz}
  echo "Paired end kallisto of ${reads1FqGz} and ${reads2FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/${uniqueID} \
    ${reads1FqGz} ${reads2FqGz}
  then
    echo "returncode: $?"; putFile ${kallistoDir}/${uniqueID}/abundance.tsv
    putFile ${kallistoDir}/${uniqueID}/abundance.h5
    putFile ${kallistoDir}/${uniqueID}/run_info.json
    cd ${kallistoDir}/${uniqueID}
    md5sum abundance.h5 > abundance.h5.md5
    md5sum run_info.json > run_info.json.md5
    md5sum abundance.tsv > abundance.tsv.md5
    cd -
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
fi

echo "## "$(date)" ##  $0 Done "
