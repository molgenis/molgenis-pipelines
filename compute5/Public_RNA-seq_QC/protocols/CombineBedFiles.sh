#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string projectDir
#list genotypeHarmonizerOutput
#string combinedBEDDir
#string plinkVersion
#string genotypeHarmonizerDir



getFile ${genotypeHarmonizerOutput}.bed
getFile ${genotypeHarmonizerOutput}.bim
getFile ${genotypeHarmonizerOutput}.fam
getFile ${genotypeHarmonizerOutput}.log

#Load module
${stage} PLINK/${plinkVersion}

#Check staging of module
${checkStage}

mkdir -p ${combinedBEDDir}


echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

{
echo "$(printf '%s.bed %s.bim %s.fam\n' $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}) $(printf '%s\n' ${genotypeHarminzerOutput[@]}))"
} > ${combinedBEDDir}combinedFiles.txt.tmp
# remove first line (e.g. first sample) as this will be used as input for plink
# to which the other samples will be merged
sed '1d' ${combinedBEDDir}combinedFiles.txt.tmp > ${combinedBEDDir}combinedFiles.txt
rm ${combinedBEDDir}combinedFiles.txt.tmp

if plink \
 --bfile ${genotypeHarmonizerOutput[0]} \
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
echo "md5sums"
md5sum ${combinedBEDDir}combinedFiles.txt
md5sum ${combinedBEDDir}combinedFiles.log
md5sum ${combinedBEDDir}combinedFiles.bed
md5sum ${combinedBEDDir}combinedFiles.bim
md5sum ${combinedBEDDir}combinedFiles.fam
md5sum ${combinedBEDDir}combinedFiles.nosex
 echo "succes moving files";
else
 # got to remove mssnps before trying to merge again
 for file in "${genotypeHarmonizerOutput[@]}"; do
  plink \
   --bfile ${file} \
   --exclude ${combinedBEDDir}combinedFiles.missnp > ${file}
 done

 if plink \
  --bfile ${genotypeHarmonizerOutput[0]} \
  --merge-list ${combinedBEDDir}combinedFiles.txt \
  --make-bed \
  --out ${combinedBEDDir}combinedFiles_remove_missnps

 then
  echo "returncode: $?";
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.txt
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.log
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.bed
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.bim
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.fam
  putFile ${combinedBEDDir}combinedFiles_remove_missnps.nosex
echo "md5sums"
md5sum ${combinedBEDDir}combinedFiles.txt
md5sum ${combinedBEDDir}combinedFiles.log
md5sum ${combinedBEDDir}combinedFiles.bed
md5sum ${combinedBEDDir}combinedFiles.bim
md5sum ${combinedBEDDir}combinedFiles.fam
md5sum ${combinedBEDDir}combinedFiles.nosex
 else
  echo "returncode: $?";
  echo "fail";
 fi
fi

echo "## "$(date)" ##  $0 Done "
