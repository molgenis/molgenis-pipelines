#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string beagleDir
#stringgenotypedChrVcfGL
#stringgenotypedChrVcfBeagleGenotypeProbabilities
#stringgenotypedChrVcf.hap.gzeitInputPrefix
#stringgenotypedChrVcf.hap.gzeitInputPostfix
#string GLibVersion
#string ngsutilsVersion
#string zlibVersion
#string bzip2Version
#string GCCversion
#string CHR

echo "## "$(date)" Start $0"

getFile $genotypedChrVcfGL}
getFile $genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz

${stage} ngs-utils/${ngsutilsVersion}
${stage} GLib/${GLibVersion}
${stage} zlib/${zlibVersion}
${stage} bzip2/${bzip2Version}
# THIS NEEDS TO BE LOADED AFTER NGS-UTILS TO PREVENT GCCXX ERROR
${stage} GCC/${GCCversion}
${checkStage}

# the output is cut up into ..PrefixChromsomePostfix because it is needed for correct folding of .hap.gzit jobs later

#Run conversion script beagle vcf to .hap.gzeit format
if $EBROOTNGSMINUTILS/prepareGenFromBeagle4_modified20160601/bin/prepareGenFromBeagle4 \
 --likelihoods $genotypedChrVcfGL} \
 --posteriors $genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \
 --threshold 0.995 \
 --output $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}
then
 echo "returncode: $?";
 # these output files are NOT gzipped, so rename them to filename without gz
 putFile $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.gen.gz
 putFile $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.gen.sample
 putFile $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.hap.gz
 putFile $genotypedChrVcf.hap.gzeitInputPrefix}${chromsome}$genotypedChrVcf.hap.gzeitInputPostfix}.hap.sample
 cd ${beagleDir}
 # want to have the base path, not full path in the md5sum file, so cd to output dir and md5sum the basepath
 bname=$(basename $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.gen.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.gen.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename $genotypedChrVcf.hap.gzeitInputPrefix}${chromsome}$genotypedChrVcf.hap.gzeitInputPostfix}.hap.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}.hap.sample)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 >&2 echo "went wrong with following command:"
 >&2 echo "$EBROOTNGSMINUTILS/prepareGenFromBeagle4_modified20160601/bin/prepareGenFromBeagle4 \\
             --likelihoods $genotypedChrVcfGL} \\
             --posteriors $genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \\
             --threshold 0.995 \\
             --output $genotypedChrVcf.hap.gzeitInputPrefix}${CHR}$genotypedChrVcf.hap.gzeitInputPostfix}"
 echo "returncode: $?";
 echo "fail";
 exit 1; 
fi

echo "## "$(date)" ##  $0 Done "

