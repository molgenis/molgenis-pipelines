#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

#string verifyBamIdDir
#string verifyBamIdToolDir
#string unifiedGenotyperDir
#string internalId
#string sampleName
#string sortedBams

echo "## "$(date)" Start $0"

mkdir -p ${verifyBamIdDir}

${verifyBamIdToolDir}verifyBamID --vcf ${unifiedGenotyperDir}${internalId}_${sampleName}.raw.vcf --bam ${sortedBams} --out ${verifyBamIdDir}${internalId}_${sampleName}

if [ ! -z "$PBS_JOBID" ]; then
   echo "## "$(date)" Collecting PBS job statistics"
   qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
