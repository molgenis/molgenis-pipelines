#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string beagleDir
#string genotypedChrVcfGL
#string genotypedChrVcfBeagleGenotypeProbabilities
#string genotypedChrVcfShapeitInputPrefix
#string GLibVersion
#string ngsutilsVersion
#string zlibVersion
#string bzip2Version


echo "## "$(date)" Start $0"

getFile ${genotypedChrVcfGL}
getFile ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz

${stage} ngs-utils/${ngsutilsVersion}
${stage} GLib/${GLibVersion}
${stage} zlib/${zlibVersion}
${stage} bzip2/${bzip2Version}
${checkStage}

#Run conversion script beagle vcf to shapeit format
if $EBROOTNGSMINUTILS/prepareGenFromBeagle4_modified20160601/bin/prepareGenFromBeagle4 \
 --likelihoods ${genotypedChrVcfGL} \
 --posteriors ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \
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

