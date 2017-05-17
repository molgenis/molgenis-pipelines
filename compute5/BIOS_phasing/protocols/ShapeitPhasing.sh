#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

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
#string tabixVersion
#string genotypedChrVcfBeagleGenotypeProbabilities

${stage} tabix/${tabixVersion}
${stage} shapeit/${shapeitVersion}
${checkStage}

echo "## "$(date)" Start $0"

# chromosomeChunks are in the format chr:start-end, parse out the chr, start and end to separate variables
echo "Shaping $chromosomeChunk"
CHR=$(echo $chromosomeChunk | cut -d':' -f1 )
position=$(echo $chromosomeChunk | cut -d':' -f2 )
start=$(echo $position | cut -d'-' -f1 )
oldStart=$start
end=$(echo $position | cut -d'-' -f2 )
oldEnd=$end

echo "CHR: $CHR"
echo "start: $start"
echo "end: $end"



mkdir -p ${shapeitDir}

# check if there is at least one SNP in this chromosome chunk overlapping on both sides
let halfWay="($start + $end) / 2"
echo "halfWay: $halfWay"
# from start to halfway check if there is a SNP. Because chromosomeChunks at the moment gets made separatly of the 
# protocols this is used, however if a small overlap was chosen this might still go wrong. Check the makeChromosomeChunks.py
# script to see if this catches all overlap
if [ ! -f ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz ];
then
  echo "${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz does not exist"
  exit 1;
fi
containsSnpsStart=$(tabix ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz  $CHR:$start-$halfWay | wc -l)
containsSnpsEnd=$(tabix ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz  $CHR:$halfWay-$end  | wc -l)
# stepsize for searching up and down stream for SNP
stepsize=100000
echo "searching if SNPs at start"
while [ $containsSnpsStart -eq 0 ] && [ $start -ge 1 ]; 
do
  # if it does not contain any SNPs, search upstream and downstream until at least one SNP is found  
  echo -n "Region $CHR:$start-$halfWay does not contain any SNPs"
  start=`expr $start - $stepsize`
  echo -n ", searching with $CHR:$start-$halfWay..."; 
  containsSnpsStart=$(tabix ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz $CHR:$start-$halfWay  | wc -l)
  echo " $containsSnpsStart SNPs"
done

echo "searching if SNPs at end"
lastSnp=$(zcat ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz | tail -1 | awk '{print $2}')
echo "lastSnp on chr ${CHR}: ${lastSnp}"
while [ ${containsSnpsEnd} -eq 0 ] && [ ${end} -le ${lastSnp} ];
do
  # if it does not contain any SNPs, search upstream and downstream until at least one SNP is found
  echo -n "Region $CHR:$halfWay-$end does not contain any SNPs"
  end=`expr $end + $stepsize`
  echo -n ", searching with $CHR:$halfWay-$end...";
  containsSnpsEnd=$(tabix ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz  $CHR:$halfWay-$end  | wc -l)
  echo " $containsSnpsEnd SNPs"
done

#Set start and end positions within chromosome length
if [ $start -le 0 ];
then
    start=1;
fi

if [ $end -ge $lastSnp ];
then
    end=$lastSnp;
fi

echo 
echo "Found SNPs on both sides, final chunk used for this job is: "
echo "CHR: $CHR"
echo "start: $start"
echo "end: $end"
snpsTotal=`expr $containsSnpsStart + $containsSnpsEnd`
echo
echo "number of snps: $snpsTotal"
echo
echo "File name will use original chunk size, $oldStart and $oldEnd"

#Run shapeit
# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
shapeit \
 -call \
 --input-gen ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.gz \
             ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.gen.sample \
 --input-init ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.gz \
              ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample \
 --input-map ${geneticMapChrPrefix}${CHR}${geneticMapChrPostfix} \
 --input-scaffold ${phasedScaffoldDir}/chr_${CHR}.haps \
                  ${phasedScaffoldDir}/chr_${CHR}.sample \
 --input-thr 1.0 \
 --thread 4 \
 --window 0.1 \
 --states 400 \
 --states-random 200 \
 --burn 0 \
 --run 12 \
 --prune 4 \
 --main 20 \
 --output-max ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.hap.gz \
             ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.hap.gz.sample \
 --output-log ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.log \
 --input-from $start \
 --input-to $end

echo "returncode: $?";
cd ${shapeitDir}
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.hap.gz)
md5sum ${bname} > ${bname}.md5
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.hap.gz.sample)
md5sum ${bname} > ${bname}.md5
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${oldStart}_${oldEnd}${shapeitPhasedOutputPostfix}.log)
md5sum ${bname} > ${bname}.md5
cd -
echo "succes moving files";


echo "## "$(date)" ##  $0 Done "
