#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=08:00:00

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
echo "Starting scramble BAM to CRAM conversion";

if scramble \
    -I cram \
    -O bam \
    -m \
    -r ${onekgGenomeFasta} \
    ${cramFileDir}${uniqueID}.cram \
    $TMPDIR/${uniqueID}.bam \
    -t 2
then
  if [ ${#reads2FqGz} -eq 0 ]; 
  then
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.bam  \
      -fq $TMPDIR/$(basename ${reads1FqGz} )
  else
    bedtools bamtofastq -i $TMPDIR/${uniqueID}.bam  \
      -fq $TMPDIR/$(basename ${reads1FqGz}) \
      -fq2 $TMPDIR/$(basename ${reads2FqGz})
   echo "fastq lines: $(wc -l $TMPDIR/$(basename ${reads1FqGz})"
   echo "BAM lines: $(samtools view $TMPDIR/${uniqueID}.bam | wc -l)"
 fi
 echo "returncode: $?";
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi


echo "## "$(date)" ##  $0 Done "






