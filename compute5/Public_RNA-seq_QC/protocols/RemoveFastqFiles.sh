#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=08:00:00

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
echo "Convert fastq to unaligned BAM";
picard FastqToSam \
        F1=$reads1FqGz \
        F2=$reads2FqGz \
        O=$TMPDIR/${uniqueID}.bam \
        SM=$uniqueID

returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "convert fastq to unalligned BAM successful"
else
  echo "ERROR: couldn't convert to fastq to unalligned BAM"
  exit 1;
fi
  
echo "Convert unaligned BAM to CRAM";
samtools view -T $onekgGenomeFasta \
                -C \
                -o  ${cramFileDir}${uniqueID}.cram \ 
                $TMPDIR/${uniqueID}.bam
returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "convert to cram successful"
else
  echo "ERROR: couldn't convert to cram"
  exit 1;
fi
                
echo "Convert CRAM to fastq";
fq1NameGz=$(basename $reads1FqGz)
fq1Name=${fq1NameGz%.gz}
fq2NameGz=$(basename $reads2FqGz)
fq2Name=${fq2NameGz%.gz}
samtools fastq \
    -@ 4 \
    -1 $TMPDIR/$fq1Name \
    -2 $TMPDIR/$fq2Name \
    $TMPDIR/${uniqueID}.bam
returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "convert CRAM to fastq successful"
else
  echo "ERROR: couldn't convert cram to fastq"
  exit 1;
fi


echo "count fastq lines"
fastq1Lines=$(wc -l $TMPDIR/$fq1Name)
fastq2Lines=$(wc -l $TMPDIR/$fq2Name)
echo "fastq1Lines: $fastq1Lines"
echo "fastq2Lines: $fastq2Lines"

echo "count original fastq lines"
originalFastq1Lines=$(wc -l ${reads1FqGz})
originalFastq2Lines=$(wc -l ${reads2FqGz})

echo "originalFastq1Lines: $originalFastq1Lines"
echo "originalFastq2lines: $originalFastq2lines"
  
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






