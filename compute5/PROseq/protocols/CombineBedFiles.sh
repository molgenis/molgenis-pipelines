#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

#string stage
#string checkStage
#string projectDir
#list genotypeHarminzerOutput
#string combinedBEDDir
#string plinkVersion
#string genotypeHarmonizerDir



getFile ${genotypeHarminzerOutput}.bed
getFile ${genotypeHarminzerOutput}.bim
getFile ${genotypeHarminzerOutput}.fam
getFile ${genotypeHarminzerOutput}.log

#Load module
${stage} PLINK/${plinkVersion}

#Check staging of module
${checkStage}

mkdir -p ${combinedBEDDir}


echo "## "$(date)" Start $0"

{
echo "$(printf '%s.bed %s.bim %s.fam\n' $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}))"
} > ${combinedBEDDir}combinedFiles.txt.tmp
# remove first line (e.g. first sample) as this will be used as input for plink
# to which the other samples will be merged
sed '1d' ${combinedBEDDir}combinedFiles.txt.tmp > ${combinedBEDDir}combinedFiles.txt
rm ${combinedBEDDir}combinedFiles.txt.tmp

if plink \
--bfile ${genotypeHarminzerOutput[0]} \
--merge-list ${combinedBEDDir}combinedFiles.txt \
--make-bed \
--out ${combinedBEDDir}combinedFiles

then
 echo "returncode: $?";
 putFile ${combinedBEDDir}combinedFiles.txt
 putFile ${combinedBEDDir}combinedFiles.log
 putFile ${combinedBEDDir}combinedFiles.bed
 putFile ${combinedBEDDir}combinedFiles.bim
 putFile ${combinedBEDDir}combinedFiles.fam
 putFile ${combinedBEDDir}combinedFiles.nosex

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
