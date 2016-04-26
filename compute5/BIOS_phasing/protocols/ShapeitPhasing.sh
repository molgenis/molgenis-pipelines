#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string shapeitDir

#string shapeitVersion

#string genotypedChrVcfShapeitInputPrefix
#string chromosome
#string phasedScaffoldDir
#string geneticMapChr


echo "## "$(date)" Start $0"


getFile ${genotypedChrVcfShapeitInputPrefix}.gen.gz
getFile ${genotypedChrVcfShapeitInputPrefix}.gen.sample
getFile ${genotypedChrVcfShapeitInputPrefix}.hap.gz
getFile ${genotypedChrVcfShapeitInputPrefix}.hap.sample


${stage} shapeit/${shapeitVersion}
${checkStage}

mkdir -p ${shapeitDir}

#Run shapeit

#Maybe input-scaffold requires gzipped haps files, check this

if shapeit \
 -call \
 --input-gen ${genotypedChrVcfShapeitInputPrefix}.gen.gz ${genotypedChrVcfShapeitInputPrefix}.gen.sample \
 --input-init ${genotypedChrVcfShapeitInputPrefix}.hap.gz ${genotypedChrVcfShapeitInputPrefix}.hap.sample \
 --input-map ${geneticMapChr} \
 --input-scaffold ${phasedScaffoldDir}/chr_${chromosome}.haps ${phasedScaffoldDir}/chr_${chromosome}.sample \
 --input-thr 1.0 \
 --thread 8 \
 --window 0.1 \
 --states 400 \
 --states-random 200 \
 --burn 0 \
 --run 12 \
 --prune 4 \
 --main 20 \
 --output-max ${shapeitPhasedOutputPrefix}.haps.gz ${shapeitPhasedOutputPrefix}.haps.sample \
 --output-log ${shapeitPhasedOutputPrefix}.log
then
 echo "returncode: $?";
 putFile ${shapeitPhasedOutputPrefix}.haps.gz
 putFile ${shapeitPhasedOutputPrefix}.haps.sample
 putFile ${shapeitPhasedOutputPrefix}.log
 cd ${beagleDir}
 bname=$(basename ${shapeitPhasedOutputPrefix}.haps.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}.haps.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}.log)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "