#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=01:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string maskedFq
#string kallistoDir
#string kallistoVersion
#string uniqueID
#string kallistoIndex
#string fragmentLength

#Load modules
${stage} Kallisto/${kallistoVersion}

#check modules
${checkStage}

mkdir -p ${kallistoDir}/${uniqueID}
echo "Single end kallisto of ${maskedFq}"
if kallisto quant \
  -i ${kallistoIndex} \
  -o ${kallistoDir}/${uniqueID} \
  --single \
  -l 200 \
  ${maskedFq}
then
    echo "succes moving files";
  else
    echo "returncode: $?";
    echo "fail";
  fi

echo "## "$(date)" ##  $0 Done "
