#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=08:00:00

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
${stage} BEDTools/${bedtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#Run scramble on 2 cores to do BAM -> CRAM conversion
echo "Starting scramble CRAM to BAM conversion";

if scramble \
    -I cram \
    -O bam \
    -m \
    -r ${onekgGenomeFasta} \
    ${cramFileDir}${uniqueID}.cram \
    $TMPDIR/${uniqueID}.bam \
    -t 1
then
  echo "Starting BAM to FASTQ conversion: sort BAM file";
  samtools sort -n -o $TMPDIR/${uniqueID}.sorted.bam $TMPDIR/${uniqueID}.bam 
  echo "count lines in BAM"
  bamlines=$(samtools view $TMPDIR/${uniqueID}.bam | wc -l)
  echo "Starting BAM to FASTQ conversion: convert sorted BAM file";
  fq1NameGz=$(basename ${reads1FqGz}
  fq1Name=${fq1NameGz%gz}
  fq2NameGz=$(basename ${reads2FqGz}
  fq2Name=${fq2NameGz%gz}
  if [ ${#reads2FqGz} -eq 0 ]; 
  then
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.bam  \
      -fq $TMPDIR/$fq1Name)
    echo "count fastq lines"
    fastq1Lines=$(wc -l $TMPDIR/$fq1Name)
    echo "fastq1Lines: $fastq1Lines"
  else
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.sorted.bam  \
      -fq $TMPDIR/$fq1Name \
      -fq2 $TMPDIR/$fq2Name
    echo "count fastq lines"
    fastq1Lines=$(wc -l $TMPDIR/$fq1Name)
    fastq2Lines=$(wc -l $TMPDIR/$fq2Name)
    echo "fastq1Lines: $fastq1Lines"
    echo "fastq2Lines: $fastq2Lines"
    originalFastq2lines=$(wc -l ${reads2FqGz})
  fi
  echo "count original fastq lines"
  originalFastq1Lines=$(wc -l ${reads1FqGz})

  echo "originalFastq1Lines: $originalFastq1Lines"
  echo "originalFastq2lines: $originalFastq2lines"
  echo "bamlines: $bamlines"
  if [ "$originalFastq1Lines" -eq "$fastq1Lines" ];
  then
    echo "Fastq1 same number of lines"
    if [ ${#reads2FqGz} -eq 0 ]; 
    then
      if [ "$originalFastq2Lines" -eq "$fastq2Lines" ];
      then
        echo "Fastq2 same number of lines"
        echo "rm $reads2FqGz"
      else
        echo "ERROR: Fastq2 not same number of lines"
        exit 1;
      fi
    fi
    echo "rm $reads1FqGz"
  else
    echo "ERROR: Fastq1 not same number of lines"
    exit 1;
  fi
  echo "returncode: $?";
  echo "succes removing files";
else
 echo "returncode: $?";
 echo "scramble failed";
 exit 1;
fi


echo "## "$(date)" ##  $0 Done "






