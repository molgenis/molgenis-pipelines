#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix

#string CHR
#string genotypedChrVcfShapeitInputPrefix
#string genotypedChrVcfShapeitInputPostfix
#string bglchunkOutfile
#string shapeitLigatedHaplotype
#string shapeitLigatedHaplotypeDir
#string scaffoldedSamplesPrefix
#string ligateHAPLOTYPESVersion
#string genotypedChrVcfGLFiltered
#string GLibVersion
#string GCCversion

echo "## "$(date)" Start $0"

${stage} ligateHAPLOTYPES/${ligateHAPLOTYPESVersion}
# Glib is also set as dependency of ligateHAPLOTYPES but still needs to be loaded after
${stage} GLib/${GLibVersion}
${stage} GCC/4.9.3-binutils-2.25
${checkStage}


shapeitInput=()
echo "looping through chunk to retrieve input files"
while read line
do
  CHR=$(echo $line | awk '{print $2}' )
  start=`echo $line | awk '{print $2}'`
  end=`echo $line | awk '{print $3}'`
  echo -n "$CHR:$start-$end "

  # since it is the correct chromsome add it to array to put as input later
  # [[ -s -> if file exists and not empty
  # because of new protocols upstream where we created bgl chunks, none of the files should be empty
  # keeping commented code around incase this has to repeated with some chunks missing
  #if [[ -s ${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz ]];
  #then 
      shapeitInput+=("${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz")
  #else
  #    echo "${shapeitPhasedOutputPrefix}${CHR}_${start}_${end}${shapeitPhasedOutputPostfix}.hap.gz is empty, skipping this chunk"
  #fi
done < ${bglchunkOutfile}

echo

# for check, echo the files we will use as input
echo "input files selected for input:"
echo "${shapeitInput[@]}"
mkdir -p ${shapeitLigatedHaplotypeDir}

awk '{print $2}' ${genotypedChrVcfShapeitInputPrefix}${CHR}${genotypedChrVcfShapeitInputPostfix}.hap.sample | tail -n +3 > ${scaffoldedSamplesPrefix}${CHR}.txt
ligateHAPLOTYPES --vcf ${genotypedChrVcfGLFiltered} \
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
