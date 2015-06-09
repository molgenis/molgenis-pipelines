#MOLGENIS walltime=23:59:00 nodes=1 mem=6gb ppn=4

#string stage
#string checkStage
#string toolDir
#string sampleName
#string unifiedGenotyperDir
#string internalId
#string genotypeHarminzerOutput
#string genotypeHarmonizerDir
#string uniqueID
#string jdkVersion
#string GenotypeHarmonizerVersion
#string rawVCF



getFile ${rawVCF}.gz

#Load modules
#${stage} jdk/${jdkVersion}

#check modules
${checkStage}

mkdir -p ${genotypeHarmonizerDir}

echo "## "$(date)" Start $0"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}GenotypeHarmonizer-${GenotypeHarmonizerVersion}/GenotypeHarmonizer.jar \
 -i ${rawVCF}.gz \
 -o ${genotypeHarminzerOutput} \
 -I VCF \
 -O PLINK_BED

then
 echo "returncode: $?"; putFile ${genotypeHarminzerOutput}.fam
 putFile ${genotypeHarminzerOutput}.log
 putFile ${genotypeHarminzerOutput}.bed
 putFile ${genotypeHarminzerOutput}.bim

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

