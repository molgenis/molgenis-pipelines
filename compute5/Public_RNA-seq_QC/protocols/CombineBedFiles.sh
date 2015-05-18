#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string projectDir
#list genotypeHarminzerOutput
#string combinedBEDDir
#string plinkVersion
#string genotypeHarmonizerDir


echo "## "$(date)" ##  $0 Started "

${stage} plink/${plinkVersion}
${checkStage}

mkdir -p ${combinedBEDDir}

{
echo "$(printf '%s.bed %s.bim %s.fam\n' $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}))"
} > ${combinedBEDDir}combinedFiles.txt


plink --merge-list ${combinedBEDDir}combinedFiles.txt --make-bed --out ${combinedBEDDir}combinedFiles

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
