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
#string prepareGenFromBeagle4Version

echo "## "$(date)" Start $0"

getFile ${genotypedChrVcfGL}
getFile ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz

${stage} prepareGenFromBeagle4/${prepareGenFromBeagle4Version}
# Glib is also set as dependency of prepareGenFromBeagle4 but still needs to be loaded after
${stage} GLib/${GLibVersion}
${checkStage}

# the output is cut up into ..PrefixChromsomePostfix because it is needed for correct folding of .hap.gzit jobs later

#Run conversion script beagle vcf to .hap.gzeit format
if prepareGenFromBeagle4 \
 --likelihoods ${genotypedChrVcfGL} \
 --posteriors ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \
 --threshold 0.995 \
 --output ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}
then
 echo "returncode: $?";
 # these output files are NOT gzipped, so rename them to filename without gz
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample
 putFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.gz
 putFile ${genotypedChrVcfShapeitInputPrefix}${chromsome}${genotypedChrVcfShapeitInputPostfix}.hap.sample
 cd ${beagleDir}
 # want to have the base path, not full path in the md5sum file, so cd to output dir and md5sum the basepath
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${chromsome}${genotypedChrVcfShapeitInputPostfix}.hap.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 >&2 echo "went wrong with following command:"
 >&2 echo "prepareGenFromBeagle4_modified20160601/bin/prepareGenFromBeagle4 \\
             --likelihoods ${genotypedChrVcfGL} \\
             --posteriors ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \\
             --threshold 0.995 \\
             --output ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}"
 echo "returncode: $?";
 echo "fail";
 exit 1; 
fi

echo "## "$(date)" ##  $0 Done "

