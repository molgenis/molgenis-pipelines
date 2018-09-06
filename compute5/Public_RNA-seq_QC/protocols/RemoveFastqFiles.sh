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
fq2NameGz=$(basename $reads2FqGz)
fq2Name=${fq2NameGz%.gz}

echo "Starting BAM to FASTQ conversion: convert sorted BAM file to fastq"
if [ ${#reads2FqGz} -eq 0 ];
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
  if [ ${#reads2FqGz} -eq 0 ];
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
      echo "ERROR: Fastq2 not same number of lines"
      exit 1;
    fi
  fi
  echo "Deleting $reads1FqGz...."
  rm $reads1FqGz
else
  echo "ERROR: Fastq1 not same number of lines"
  exit 1;
fi

echo "final returncode: $?";
echo "succes removing files";


echo "## "$(date)" ##  $0 Done "






