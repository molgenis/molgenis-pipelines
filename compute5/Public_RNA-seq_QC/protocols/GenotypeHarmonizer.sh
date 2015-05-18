#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

#string stage
#string checkStage
#string toolDir
#string genotypeHarmonizerToolDir
#string sampleName
#string unifiedGenotyperDir
#string internalId
#string genotypeHarminzerOutput
#string genotypeHarmonizerDir

echo "## "$(date)" Start $0"

#Load modules
${stage} jdk

#check modules
${checkStage}

mkdir -p ${genotypeHarmonizerDir}

java -Xmx6g -XX:ParallelGCThreads=4 -jar ${genotypeHarmonizerToolDir}GenotypeHarmonizer.jar -i ${unifiedGenotyperDir}${internalId}_${sampleName}.raw.vcf.gz -o ${genotypeHarminzerOutput} -I VCF -O PLINK_BED


if [ ! -z "$PBS_JOBID" ]; then
   echo "## "$(date)" Collecting PBS job statistics"
   qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
