#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix
#string shapeitVersion

#string genotypedChrVcfShapeitInputPrefix
#string genotypedChrVcfShapeitInputPostfix
#list chromosomeChunk
#string CHR
#string phasedScaffoldDir
#string geneticMapChrPrefix
#string geneticMapChrPostfix
#string shapeitLigatedHaplotype
#string shapeitLigatedHaplotypeDir

echo "## "$(date)" Start $0"

${stage} shapeit/${shapeitVersion}
${checkStage}


i=0
for chunk in "${chromosomeChunk[@]}"
do
  # chromosomeChunks are in the format chr:start-end, parse out the chr, start and end to separate variables
  CHR_from_chunk=$(echo $chromosomeChunk | cut -d':' -f1 | read str1)
  if [ "$CHR_from_chunk" == "$CHR" ];
  then 
    position=$(echo $chromosomeChunk | cut -d':' -f1 | read str2)
    start=$(echo $position | cut -d'-' -f1 | read str1)
    end=$(echo $position | cut -d'-' -f1 | read str2)
    getFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps
    getFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps.sample
    # since it is the correct chromsome add it to array to put as input later
    shapeitInput[i]=${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.haps
    i=$(($i+1))
  fi
done

# for check, echo the files we will use as input
echo "input files selected for input:"
for inputFile in "${shapeitInput[@]}"
do
  echo "$inputFile"
done

mkdir -p ${shapeitLigatedHaplotypesDir}
echo "Shaping $chromosomeChunk"

# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init from ShapeitPhasing step). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
# have to get the scaffolded samples from the vcf file
awk '{print $2}' ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.sample > ${scaffoldedSamples}
if ligateHAPLOTYPES --vcf ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap \
                 --scaffold ${scaffoldedSamples} \
                 --chunks ${shapeitInput} \
                 --output ${shapeitLigatedHaplotype}
then
 echo "returncode: $?";
 putFile ${shapeitLigatedHaplotype}
 cd ${shapeitLigatedHaplotypesDir}
 bname=$(basename ${shapeitLigatedHaplotype})
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "## "$(date)" ##  $0 Done "
