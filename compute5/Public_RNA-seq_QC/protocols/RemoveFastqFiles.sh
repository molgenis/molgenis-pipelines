#MOLGENIS nodes=1 ppn=4 mem=12gb walltime=08:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string picardVersion
#string iolibVersion
#string unfilteredBamDir
#string cramFileDir
#string tmpCramFileDir
#string onekgGenomeFasta
#string uniqueID
#string reads1FqGz
#string reads2FqGz
#string samtoolsVersion
#string bedtoolsVersion

# Get input file

#Load modules
${stage} picard/${picardVersion}
${stage} io_lib/${iolibVersion}
${stage} SAMtools/${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#Run scramble on 2 cores to do BAM -> CRAM conversion
echo "Starting scramble CRAM to BAM conversion";

if [ ! -f ${reads1FqGz} ];
then
    echo "ERROR: ${reads1FqGz} does not exist"
    exit 1;
fi

if [ ${#reads2FqGz} -eq 0 ]; then
    seqType="SR"
else
    seqType="PE"

    if [ ! -f ${reads2FqGz} ];
    then
        echo "ERROR: ${reads2FqGz} does not exist"
        exit 1;
    fi
fi

scramble \
    -I cram \
    -O bam \
    -m \
    -r ${onekgGenomeFasta} \
    ${cramFileDir}${uniqueID}.cram \
    $TMPDIR/${uniqueID}.bam \
    -t 4

returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "convert CRAM to BAM successful"
else
  echo "ERROR: couldn't convert to CRAM to BAM"
  exit 1;
fi

echo "Starting BAM to FASTQ conversion: sort BAM file";
samtools sort \
    -@ 4 \
    -n \
    -o $TMPDIR/${uniqueID}.sorted.bam \
    $TMPDIR/${uniqueID}.bam
rm $TMPDIR/${uniqueID}.bam

returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "sorting BAM successful"
else
  echo "ERROR: couldn't sort BAM"
  exit 1;
fi

# get the filenames from the full path
fq1NameGz=$(basename $reads1FqGz)
fq1Name=${fq1NameGz%.gz}

if [ ${seqType} == "PE" ]
then
    fq2NameGz=$(basename $reads2FqGz)
    fq2Name=${fq2NameGz%.gz}
fi



echo "Starting BAM to FASTQ conversion: convert sorted BAM file to fastq"
if [ ${seqType} == "SR" ]
then
  samtools fastq \
      -@ 4 \
      -0 $TMPDIR/$fq1Name \
      $TMPDIR/${uniqueID}.sorted.bam
    echo "count fastq lines"
    fastq1Lines=$(cat $TMPDIR/$fq1Name | wc -l)
    echo "fastq1Lines: $fastq1Lines"
else
  samtools fastq \
      -@ 4 \
      -1 $TMPDIR/$fq1Name \
      -2 $TMPDIR/$fq2Name \
      $TMPDIR/${uniqueID}.sorted.bam

  echo "count fastq lines"
  fastq1Lines=$(cat $TMPDIR/$fq1Name | wc -l)
  fastq2Lines=$(cat $TMPDIR/$fq2Name | wc -l)
  echo "fastq1Lines: $fastq1Lines"
  echo "fastq2Lines: $fastq2Lines"
  originalFastq2Lines=$(zcat ${reads2FqGz} | wc -l)
fi

returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "convert BAM to fastq successful"
else
  echo "ERROR: couldn't convert BAM to fastq"
  exit 1;
fi


echo "count original fastq lines"
originalFastq1Lines=$(zcat ${reads1FqGz} | wc -l)


echo "originalFastq1Lines: $originalFastq1Lines"
if [ "$originalFastq1Lines" -eq "$fastq1Lines" ];
then
  echo "Fastq1 same number of lines"
  if [ ${seqType} == "SR" ]
  then
    :
  else
      echo "originalFastq2Lines: $originalFastq2Lines"
    if [ "$originalFastq2Lines" -eq "$fastq2Lines" ];
    then
      echo "Fastq2 same number of lines"
      echo "Deleting $reads2FqGz...."
      rm $reads2FqGz
    else
      echo "try to see if there is only 1 read difference between the two"
      fastq2LinesPlusOneRead=`expr $fastq2Lines + 4`
      echo "Number of lines: $fastq2LinesPlusOneRead"
      if [ "$originalFastq2Lines" -eq "$fastq2LinesPlusOneRead" ];
      then
        echo "only 1 read missing, will still delete"
      else
        echo "ERROR: Fastq2 not same number of lines"
        exit 1;
      fi
    fi
  fi
  echo "Deleting $reads1FqGz...."
  rm $reads1FqGz
else
  echo "try to see if there is only 1 read difference between the two"
  fastq1LinesPlusOneRead=`expr $fastq1Lines + 4`
  echo "Number of lines: $fastq1LinesPlusOneRead"
  if [ "$originalFastq1Lines" -eq "$fastq1LinesPlusOneRead" ];
  then
    echo "only 1 read missing, will still delete"
  else
    echo "ERROR: Fastq1 not same number of lines"
    exit 1;
  fi
fi

echo "final returncode: $?";
echo "succes removing files";


echo "## "$(date)" ##  $0 Done "







