#MOLGENIS walltime=23:59:00 nodes=1 mem=6gb ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string toolDir
#string unifiedGenotyperDir
#string genotypeHarmonizerOutput
#string genotypeHarmonizerDir
#string uniqueID
#string jdkVersion
#string genotypeHarmonizerVersion
#string rawVCF



getFile ${rawVCF}.gz

#Load modules
${stage} GenotypeHarmonizer/${genotypeHarmonizerVersion}

#check modules
${checkStage}

mkdir -p ${genotypeHarmonizerDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar ${toolDir}GenotypeHarmonizer/${GenotypeHarmonizerVersion}/GenotypeHarmonizer.jar \
 -i ${rawVCF}.gz \
 -o ${genotypeHarmonizerOutput} \
 -I VCF \
 -O PLINK_BED

then
 echo "returncode: $?"; putFile ${genotypeHarmonizerOutput}.fam
 putFile ${genotypeHarmonizerOutput}.log
 putFile ${genotypeHarmonizerOutput}.bed
 putFile ${genotypeHarmonizerOutput}.bim
cd ${genotypeHarmonizerDir}
md5sum $(basename ${genotypeHarmonizerOutput}).log > $(basename ${genotypeHarmonizerOutput}).log.md5
md5sum $(basename ${genotypeHarmonizerOutput}).fam > $(basename ${genotypeHarmonizerOutput}).fam.md5
cd - 
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

