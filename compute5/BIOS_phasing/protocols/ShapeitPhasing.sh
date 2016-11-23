#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string shapeitDir
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix
#string shapeitVersion

#string genotypedChrVcfShapeitInputPrefix
#string genotypedChrVcfShapeitInputPostfix
#string chromosomeChunk
#string phasedScaffoldDir
#string geneticMapChrPrefix
#string geneticMapChrPostfix

${stage} shapeit/${shapeitVersion}
${checkStage}

echo "## "$(date)" Start $0"

# chromosomeChunks are in the format chr:start-end, parse out the chr, start and end to separate variables
echo "Shaping $chromosomeChunk"
CHR=$(echo $chromosomeChunk | cut -d':' -f1 )
position=$(echo $chromosomeChunk | cut -d':' -f2 )
start=$(echo $position | cut -d'-' -f1 )
end=$(echo $position | cut -d'-' -f1 )

echo "CHR: $CHR"
echo "start: $start"
echo "end: $end"

getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample



mkdir -p ${shapeitDir}


#Run shapeit
# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
if shapeit \
 -call \
 --input-gen ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen \
             ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample \
 --input-init ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap \
              ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample \
 --input-map ${geneticMapChrPrefix}${CHR}${geneticMapChrPostfix} \
 --input-scaffold ${phasedScaffoldDir}/chr_${CHR}.haps ${phasedScaffoldDir}/chr${CHR}.sample \
 --input-thr 1.0 \
 --thread 8 \
 --window 0.1 \
 --states 400 \
 --states-random 200 \
 --burn 0 \
 --run 12 \
 --prune 4 \
 --main 20 \
 --output-max ${shapeitPhasedOutputPrefix}/chr${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps ${shapeitPhasedOutputPrefix}/chr${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps.sample \
 --output-log ${shapeitPhasedOutputPrefix}/chr${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log \
 --input-from $start \
 --input-to $end
then
 echo "returncode: $?";
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps.sample
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log
 cd ${shapeitDir}
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "## "$(date)" ##  $0 Done "
