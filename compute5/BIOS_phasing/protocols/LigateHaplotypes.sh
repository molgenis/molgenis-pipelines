#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix

#string genotypedChrVcfShapeitInputPrefix
#string genotypedChrVcfShapeitInputPostfix
#list chromosomeChunk
#list CHR
#string phasedScaffoldDir
#string geneticMapChrPrefix
#string geneticMapChrPostfix
#string shapeitLigatedHaplotype
#string shapeitLigatedHaplotypeDir
#string scaffoldedSamplesPrefix
#string ligateHAPLOTYPESVersion
#string genotypedChrVcfGL
#string GLibVersion
#string zlibVersion
#string bzip2Version
#string GCCversion

echo "## "$(date)" Start $0"

${stage} ligateHAPLOTYPES/${ligateHAPLOTYPESVersion}
# Glib is also set as dependency of ligateHAPLOTYPES but still needs to be loaded after
${stage} GLib/${GLibVersion}
${stage} GCC/4.9.3-binutils-2.25
${checkStage}


shapeitInput=()
echo "looping through chunk to retrieve input files"
for chunk in "${chromosomeChunk[@]}"
do
  # chromosomeChunks are in the format chr:start-end, parse out the chr, start and end to separate variables
  CHR=$(echo $chunk | cut -d':' -f1 )
  position=$(echo $chunk | cut -d':' -f2 )
  start=$(echo $position | cut -d'-' -f1 )
  end=$(echo $position | cut -d'-' -f2 ) 
  echo -n "$CHR:$start-$end "

  # since it is the correct chromsome add it to array to put as input later
  # [[ -s -> if file exists and not empty
  if [[ -s ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz ]];
  then 
      shapeitInput+=("${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz")
  else
      echo "${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz is empty, skipping this chunk"
  fi
done
echo

# for check, echo the files we will use as input
echo "input files selected for input:"
echo "${shapeitInput[@]}"

mkdir -p ${shapeitLigatedHaplotypeDir}
echo "Shaping $chromosomeChunk"

# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init from ShapeitPhasing step). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
# have to get the scaffolded samples from the vcf file
awk '{print $2}' ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample | tail -n +3 > ${scaffoldedSamplesPrefix}${CHR}.txt
ligateHAPLOTYPES --vcf ${genotypedChrVcfGL} \
                 --scaffold ${scaffoldedSamplesPrefix}${CHR}.txt \
                 --chunks ${shapeitInput[@]} \
                 --output ${shapeitLigatedHaplotype} ${shapeitLigatedHaplotype%.haps}.sample

echo "returncode: $?";
cd ${shapeitLigatedHaplotypeDir}
bname=$(basename ${shapeitLigatedHaplotype})
md5sum ${bname} > ${bname}.md5
cd -
echo "succes moving files";

echo "## "$(date)" ##  $0 Done "
