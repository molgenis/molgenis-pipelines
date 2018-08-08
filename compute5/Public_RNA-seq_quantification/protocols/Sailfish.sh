#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string reads1FqGz
#string reads2FqGz
#string sailfishDir
#string sailfishVersion
#string uniqueID
#string sailfishIndex
#string libType
#string numBootstraps
#string flags

#Load modules
${stage} Sailfish/${sailfishVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

outDir=${sailfishDir}/${uniqueID}/
mkdir -p $outDir


if [ ${#reads2FqGz} -eq 0 ]; then
  echo "Single end Sailfish of ${reads1FqGz}"
  # don't know how to determine libType from the fastq files, so defined in parameter file..
  # TODO: add a check if the libtype is compatible with the quant option
  if sailfish quant \
        -i ${sailfishIndex} \
        -l ${libType} \
        -r <(gunzip -c $reads1FqGz) \
        -o $outDir} \
        --numBootstraps ${numBootstraps} \
        ${flags}
  then
    echo "returncode: $?";
  else
    echo "returncode: $?";
    echo "fail";
    exit 1;
  fi
else 
  if sailfish quant \
        -i ${sailfishIndex} \
        -l ${libType} \
        -1 <(gunzip -c $reads1FqGz) -2 <(gunzip -c $reads2FqGz) \
        -o $outDir \
        --numBootstraps ${numBootstraps} \
        ${flags}
  then
    echo "returncode: $?";
  else
    echo "returncode: $?";
    echo "fail";
    exit 1;
  fi
fi

echo "## "$(date)" ##  $0 Done "
