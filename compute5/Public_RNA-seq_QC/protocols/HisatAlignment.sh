#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

#string stage
#string checkStage
#string referenceGenome
#string sampleName
#string reads1FqGz
#string nTreads
#string internalId
#string platform
#string hisatAlignmentDir

echo "## "$(date)" Start $0"

#Load modules
${stage} hisat

#check modules
${checkStage}

mkdir -p ${hisatAlignmentDir}

hisat -x ${referenceGenome} -S ${hisatAlignmentDir}${internalId}_${sampleName}.sam -U ${reads1FqGz} -p $nTreads --rg-id ${internalId} --rg PL:${platform} --rg PU:${sampleName}_${internalId}_${internalId} --rg LB:${sampleName}_${internalId} --rg SM:${sampleName}


if [ ! -z "$PBS_JOBID" ]; then
   echo "## "$(date)" Collecting PBS job statistics"
   qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
