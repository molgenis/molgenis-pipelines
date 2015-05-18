#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

#string stage
#string checkStage
#string sampleName
#string nTreads
#string internalId
#string platform
#string picardVersion
#string toolDir
#string hisatAlignmentDir
#string sortedBamDir
#string sortedBams
#string sortedBais

echo "## "$(date)" Start $0"

#Load modules
${stage} jdk

#check modules
${checkStage}

mkdir -p ${sortedBamDir}

java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}picard-tools-${picardVersion}/SortSam.jar INPUT=${hisatAlignmentDir}${internalId}_${sampleName}.sam OUTPUT=${sortedBams} SO=coordinate CREATE_INDEX=true

putFile ${sortedBams}
putFile ${sortedBais}

if [ ! -z "$PBS_JOBID" ]; then
   echo "## "$(date)" Collecting PBS job statistics"
   qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
