#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

#string stage
#string checkStage
#string projectDir
#list genotypeHarminzerOutput
#string combinedBEDDir
#string plinkVersion
#string genotypeHarmonizerDir

set -u
set -e

function returnTest {
  return $1
}

getFile ${genotypeHarminzerOutput}

${stage} plink/${plinkVersion}
${checkStage}

mkdir -p ${combinedBEDDir}


echo "## "$(date)" ##  $0 Started "

{
echo "$(printf '%s.bed %s.bim %s.fam\n' $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}))"
} > ${combinedBEDDir}combinedFiles.txt


plink --merge-list ${combinedBEDDir}combinedFiles.txt --make-bed --out ${combinedBEDDir}combinedFiles

echo "## "$(date)" ##  $0 Done "

if returnTest \
  0;
then
  echo "returncode: $?";
  echo "succes moving files";
else
  echo "returncode: $?";
  echo "fail";
fi