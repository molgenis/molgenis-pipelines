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

mkdir -p ${sailfishDir}




if [ ${#reads2FqGz} -eq 0 ]; then
  tmpFastq1=$TMPDIR/$(basename $reads1FqGz)
  echo "extracting  $reads1FqGz to $tmpFastq1"
  zcat $reads2FqGz > tmpFastq1;
  echo "Single end Sailfish of ${reads1FqGz}"
  # don't know how to determine libType from the fastq files, so defined in parameter file..
  # TODO: add a check if the libtype is compatible with the quant option
  if sailfish quant \
        -i ${sailfishIndex} \
        -l ${libType} \
        -r $tmpFastq1 \
        -o ${sailfishDir} \
        --numBootstraps ${numBootstraps} \
        ${flags}
  then
    echo "returncode: $?";
    rm $tmpFastq1
  else
    echo "returncode: $?";
    echo "fail";
    rm $tmpFastq1
    exit 1;
  fi
else 
  tmpFastq1=$TMPDIR/$(basename $reads1FqGz)
  echo "extracting  $reads1FqGz to $tmpFastq1"
  zcat $reads2FqGz > tmpFastq1;
  tmpFastq2=$TMPDIR/$(basename $reads2FqGz)
  echo "extracting  $reads2FqGz to $tmpFastq2"
  zcat $reads2FqGz > tmpFastq2;
  echo "Paired end sailfish of ${reads1FqGz} and ${reads2FqGz}"
  if sailfish quant \
        -i ${sailfishIndex} \
        -l ${libType} \
        -1 $tmpFastq1 -2 $tmpFastq2 \
        -o ${sailfishDir} \
        --numBootstraps ${numBootstraps} \
        ${flags}
  then
    echo "returncode: $?";
    rm $tmpFastq1
    rm $tmpFastq2
  else
    echo "returncode: $?";
    echo "fail";
    rm $tmpFastq1
    rm $tmpFastq2
    exit 1;
  fi
fi

echo "## "$(date)" ##  $0 Done "
