#MOLGENIS nodes=1 ppn=1 mem=16gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string fastqcDir
#string collectMultipleQcMetricsDir
#string alignmentDir
#string multiqcAlignmentDir
#string collectRnaSeqQcMetricsDir
#string variantEvalDir
#string verifyBamIdDir

module load multiqc/1.6-foss-2015b-Python-2.7.11

multiqc ${fastqcDir} ${collectMultipleQcMetricsDir} ${alignmentDir} ${collectRnaSeqQcMetricsDir} ${verifyBamIdDir} ${variantEvalDir} -f -o ${multiqcAlignmentDir}

returnCode=$?
echo "returncode: $returnCode";
if [ $returnCode -eq 0 ]
then
  echo "multiqc succesful"
else
  echo "ERROR: mulqtic failed"
  exit 1;
fi



echo "## "$(date)" ##  $0 Done "
