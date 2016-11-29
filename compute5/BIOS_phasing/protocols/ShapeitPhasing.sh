#MOLGENIS walltime=23:59:00 mem=16gb nodes=1 ppn=8

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
end=$(echo $position | cut -d'-' -f2 )

echo "CHR: $CHR"
echo "start: $start"
echo "end: $end"

getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.gz
getFile ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample



mkdir -p ${shapeitDir}


#Run shapeit
# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
if shapeit \
 -call \
 --input-gen ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz \
             ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample \
 --input-init ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.gz \
              ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample \
 --input-map ${geneticMapChrPrefix}${CHR}${geneticMapChrPostfix} \
 --input-scaffold ${phasedScaffoldDir}/chr_${CHR}.haps \
                  ${phasedScaffoldDir}/chr_${CHR}.sample \
 --input-thr 1.0 \
 --thread 8 \
 --window 0.1 \
 --states 400 \
 --states-random 200 \
 --burn 0 \
 --run 12 \
 --prune 4 \
 --main 20 \
 --output-max ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz \
             ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz.sample \
 --output-log ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log \
 --input-from $start \
 --input-to $end
then
 echo "returncode: $?";
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz.sample
 putFile ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log
 cd ${shapeitDir}
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz.sample)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
  >&2 echo "went wrong with following command:"
 >&2 echo "shapeit \\
 -call \\
 --input-gen /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//beagle//lld_plus_gonl.chr${CHR}.beagle.genotype.probs.gg.gen.gz \\
             /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//beagle//lld_plus_gonl.chr${CHR}.beagle.genotype.probs.gg.gen.sample \\
 --input-init /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//beagle//lld_plus_gonl.chr${CHR}.beagle.genotype.probs.gg.hap.gz \\
              /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//beagle//lld_plus_gonl.chr${CHR}.beagle.genotype.probs.gg.hap.sample \\
 --input-map /apps/data/www.shapeit.fr/genetic_map_b37//genetic_map_chr${CHR}_combined_b37.txt \\
 --input-scaffold /groups/umcg-lld/tmp04/projects/genotypingRelease3/selectionLldeep/lldeepPhased//chr_${CHR}.haps \\
                  /groups/umcg-lld/tmp04/projects/genotypingRelease3/selectionLldeep/lldeepPhased//chr_${CHR}.sample \\
 --input-thr 1.0 \
 --thread 8 \
 --window 0.1 \
 --states 400 \
 --states-random 200 \
 --burn 0 \
 --run 12 \
 --prune 4 \
 --main 20 \
 --output-max /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//shapeit//lld_plus_gonl.chr${CHR}_${start}_${end}.shapeit.phased.hap.gz \\
              /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//shapeit//lld_plus_gonl.chr${CHR}_${start}_${end}.shapeit.phased.hap.gz.sample \\
 --output-log /groups/umcg-bios/tmp04/projects/lld_gvcfs/phasing/results_GQ20_callrate50//shapeit//lld_plus_gonl.chr${CHR}_${start}_${end}.shapeit.phased.log \\
 --input-from $start \\
 --input-to $end"

 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "## "$(date)" ##  $0 Done "
