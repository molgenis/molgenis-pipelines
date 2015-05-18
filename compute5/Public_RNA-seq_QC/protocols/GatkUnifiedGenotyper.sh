#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

#string stage
#string checkStage
#string onekgGenomeFasta
#string gatkVersion
#list sortedBams
#string sampleName
#string unifiedGenotyperDir
#string internalId
#string dbsnpVcf
#string toolDir
#string testIntervalList
#string tabixToolDir
#string rawVCF

echo "## "$(date)" Start $0"

#Load modules
${stage} jdk

#check modules
${checkStage}

mkdir -p ${unifiedGenotyperDir}

#print like '-I=file1.bam -I=file2.bam '
inputs=$(printf ' -I %s ' $(printf '%s\n' ${sortedBams[@]}))

java -Xmx10g -jar ${toolDir}GATK-${gatkVersion}/GenomeAnalysisTK.jar -R ${onekgGenomeFasta} -T UnifiedGenotyper $inputs -L ${testIntervalList} --dbsnp ${dbsnpVcf} -o ${rawVCF} -U ALLOW_N_CIGAR_READS -rf ReassignMappingQuality -DMQ 60

# have to gzip for GenomeHarnomizer use later
${tabixToolDir}bgzip -c ${unifiedGenotyperDir}${internalId}_${sampleName}.raw.vcf > ${unifiedGenotyperDir}${internalId}_${sampleName}.raw.vcf.gz
${tabixToolDir}tabix -p vcf ${unifiedGenotyperDir}${internalId}_${sampleName}.raw.vcf.gz

if [ ! -z "$PBS_JOBID" ]; then
echo "## "$(date)" Collecting PBS job statistics"
qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
