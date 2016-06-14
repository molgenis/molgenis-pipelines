#MOLGENIS walltime=16:00:00 mem=15gb

#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string genotypeHarmonizerVersion
#string projectDir
#string trityperDir
#string imputedVcf
echo "## "$(date)" Start $0"

#Load gatk module
${stage} GenotypeHarmonizer/${genotypeHarmonizerVersion}
${checkStage}

mkdir -p ${trityperDir}

java -jar -Xmx6g -XX:ParallelGCThreads=4 $EBROOTGENOTYPEHARMONIZER/GenotypeHarmonizer.jar  \
  --input ${imputedVcf} \
  --outputType TRITYPER \
  --output ${trityperDir} \
  --inputType VCF
echo "## "$(date)" ##  $0 Done "
