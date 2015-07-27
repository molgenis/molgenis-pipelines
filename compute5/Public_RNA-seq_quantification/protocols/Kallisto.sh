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

getFile ${reads1FqGz}

#Load modules
${stage} kallisto/${kallistoVersion}

#check modules
${checkStage}


echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if [ ${#reads2FqGz} -eq 0 ]; then
  mkdir -p ${kallistoDir}_200
  echo "Single end kallisto of ${reads1FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/SRP034691/SRS518677/SRR1057370_200 \
    --single \
    -l 200 \
    ${reads1FqGz}
  then
    echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}.sam
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
else
  mkdir -p ${kallistoDir}
  getFile ${reads2FqGz}
  echo "Paired end kallisto of ${reads1FqGz} and ${reads2FqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${kallistoDir}/ERP006215/ERS529346/ERR737789 \
    ${reads1FqGz} ${reads2FqGz}
  then
    echo "returncode: $?"; putFile ${hisatAlignmentDir}${uniqueID}.sam
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi
fi

echo "## "$(date)" ##  $0 Done "
