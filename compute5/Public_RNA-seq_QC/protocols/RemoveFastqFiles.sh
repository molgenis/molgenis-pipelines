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
  samtools sort -n $TMPDIR/${uniqueID}.bam $TMPDIR/${uniqueID}.sorted.bam
  echo "count lines in BAM"
  bamlines=$(samtools view $TMPDIR/${uniqueID}.bam | wc -l)
  echo "Starting BAM to FASTQ conversion: convert sorted BAM file";

  if [ ${#reads2FqGz} -eq 0 ]; 
  then
  
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.bam  \
      -fq $TMPDIR/$(basename ${reads1FqGz})
    fastq1Lines=$(wc -l $TMPDIR/$(basename ${reads1FqGz})
    echo "fastq1Lines: $fastq1Lines"
    totalLines=$fastq1Lines
  else
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.sorted.bam  \
      -fq $TMPDIR/$(basename ${reads1FqGz}) \
      -fq2 $TMPDIR/$(basename ${reads2FqGz})
    fastq1Lines=$(wc -l $TMPDIR/$(basename ${reads1FqGz})
    fastq2Lines=$(wc -l $TMPDIR/$(basename ${reads2FqGz})
    echo "fastq1Lines: $fastq1Lines"
    echo "fastq2Lines: $fastq2Lines"
    totalLines=`expr "$fastq1Lines" + "$fastq2Lines"`
  fi
  echo "totalLines: $totalLines"
  echo "bamlines: $bamlines"
  if [ "$totalLines" -eq "$bamlines" ];
  then
    echo "Same number of lines, removing fastq"
    echo "rm $reads1FqGz"
    echo "rm $reads2FqGz"
  else
    echo "ERROR: different number of lines"
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






