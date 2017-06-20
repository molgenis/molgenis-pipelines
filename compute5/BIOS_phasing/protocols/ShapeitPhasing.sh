#MOLGENIS walltime=0:30:00 mem=4gb nodes=1 ppn=1

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

#string CHR
#string bglchunkOutfile
#string bglchunkDir
#string genotypedChrVcfShapeitInputPrefix
#string genotypedChrVcfShapeitInputPostfix
#string phasedScaffoldDir
#string geneticMapChrPrefix
#string geneticMapChrPostfix
#string tabixVersion
#string shapeitJobsDir


echo "## "$(date)" Start $0"

mkdir -p ${bglchunkDir}
mkdir -p ${shapeitJobsDir}

# echo the jobs to protocol files and then sbatch them
while read line
do
    start=`echo $line | awk '{print $2}'`
    end=`echo $line | awk '{print $3}'`
    chunk="ShapeitPhasing_chunk_${CHR}.$start.$end"

    echo "#!/bin/bash
#SBATCH --job-name=ShapeitPhasing_chunk_${chunk}
#SBATCH --output=ShapeitPhasing_chunk_${chunk}.out
#SBATCH --error=ShapeitPhasing_chunk_${chunk}.err
#SBATCH --time=23:59:00
#SBATCH --cpus-per-task 4
#SBATCH --mem 8gb
#SBATCH --open-mode=append
#SBATCH --export=NONE
#SBATCH --get-user-env=30L
#SBATCH --qos=leftover

set -e
set -u


trap 'errorExitAndCleanUp HUP  NA $?' HUP
trap 'errorExitAndCleanUp INT  NA $?' INT
trap 'errorExitAndCleanUp QUIT NA $?' QUIT
trap 'errorExitAndCleanUp TERM NA $?' TERM
trap 'errorExitAndCleanUp EXIT NA $?' EXIT
trap 'errorExitAndCleanUp ERR  $LINENO $?' ERR


echo \"## \"$(date)\" Start $0\"
module load tabix/${tabixVersion}
module load shapeit/${shapeitVersion}
module list

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
 --output-max ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz \
             ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz.sample \
 --output-log ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log \
 --input-from $start \
 --input-to $end

echo \"returncode: \$?\";
cd ${shapeitDir}
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz)
md5sum \${bname} > \${bname}.md5
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz.sample)
md5sum \${bname} > \${bname}.md5
bname=$(basename ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.log)
md5sum \${bname} > \${bname}.md5
cd -
echo \"succes moving files\";


echo \"## \"\$(date)\" ##  $0 Done \"

trap - EXIT
exit 0
" > ${shapeitJobsDir}/ShapeitPhasing_chunk_${chunk}.sh
echo "Submitting shapeit chunk ${chunk}"
echo "Job and logs written to ${shapeitJobsDir}"
cd ${shapeitJobsDir}
sbatch ShapeitPhasing_chunk_${chunk}.sh
cd -

done < ${bglchunkOutfile}

echo "## "$(date)" ##  $0 Done "
