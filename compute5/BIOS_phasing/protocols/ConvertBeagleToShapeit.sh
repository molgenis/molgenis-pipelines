#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string genotypedChrVcfGL
#string genotypedChrVcfTbi
#string genotypedChrVcfBeagleGenotypeProbabilities
#string genotypedChrVcfShapeitInputPrefix


echo "## "$(date)" Start $0"

getFile ${genotypedChrVcfGL}
getFile ${genotypedChrVcfTbi}
getFile ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz

${stage} GLib/${GLibVersion}
${checkStage}

#Run conversion script beagle vcf to shapeit format
if /groups/umcg-bios/tmp04/umcg-fvandijk/projects/beagleTest/prepareGenFromBeagle4 \
 --likelihoods ${genotypedChrVcfGL} \
 --posteriors ${genotypedChrVcfBeagleGenotypeProbabilities} \
 --threshold 0.995 \
 --output ${genotypedChrVcfShapeitInputPrefix}
then
 echo "returncode: $?";
 putFile ${genotypedChrVcfShapeitInputPrefix}.gen.gz
 putFile ${genotypedChrVcfShapeitInputPrefix}.gen.sample
 putFile ${genotypedChrVcfShapeitInputPrefix}.hap.gz
 putFile ${genotypedChrVcfShapeitInputPrefix}.hap.sample
 cd ${beagleDir}
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}.gen.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}.gen.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}.hap.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}.hap.sample)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

