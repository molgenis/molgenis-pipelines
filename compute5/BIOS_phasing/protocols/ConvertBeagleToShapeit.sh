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
#string genotypedChrVcfShapeitInputPostfix
#string GLibVersion
#string ngsutilsVersion
#string zlibVersion
#string bzip2Version
#string GCCversion
#string CHR

echo "## "$(date)" Start $0"

getFile ${genotypedChrVcfGL}
getFile ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz

${stage} ngs-utils/${ngsutilsVersion}
${stage} GLib/${GLibVersion}
${stage} zlib/${zlibVersion}
${stage} bzip2/${bzip2Version}
# THIS NEEDS TO BE LOADED AFTER NGS-UTILS TO PREVENT GCCXX ERROR
${stage} GCC/${GCCversion}
${checkStage}

# the output is cut up into ..PrefixChromsomePostfix because it is needed for correct folding of Shapit jobs later

#Run conversion script beagle vcf to shapeit format
if $EBROOTNGSMINUTILS/prepareGenFromBeagle4_modified20160601/bin/prepareGenFromBeagle4 \
 --likelihoods ${genotypedChrVcfGL} \
 --posteriors ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \
 --threshold 0.995 \
 --output ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}
then
 echo "returncode: $?";
 # these output files are NOT gzipped, so rename them to filename without gz
 mv ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample
 mv ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.gz ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap
 putFile ${genotypedChrVcfShapeitInputPrefix}${chromsome}${genotypedChrVcfShapeitInputPostfix}.hap.sample
 cd ${beagleDir}
 # want to have the base path, not full path in the md5sum file, so cd to output dir and md5sum the basepath
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${chromsome}${genotypedChrVcfShapeitInputPostfix}.hap)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

