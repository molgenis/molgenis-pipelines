#MOLGENIS walltime=23:59:00 mem=12gb ppn=8


#string stage
#string gatkVersion
#string checkStage
#string tmpTmpDataDir
#string tmpDataDir
#string indexFile
#string splitAndTrimBam,splitAndTrimBai
#string intermediateDir
#string externalSampleID
#string dbsnpVcf
#string dbSNPFileID
#string GatkHaplotypeCallerGvcf
#string GatkHaplotypeCallerGvcfidx
#string project
#string groupname
#string tmpName

makeTmpDir ${GatkHaplotypeCallerGvcf}
tmpGatkHaplotypeCallerGvcf=${MC_tmpFile}

makeTmpDir ${GatkHaplotypeCallerGvcfidx}
tmpGatkHaplotypeCallerGvcfidx=${MC_tmpFile}

array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

inputs=()
for SampleID in "${splitAndTrimBam[@]}"
do
        array_contains inputs "-I $SampleID" || inputs+=("-I $SampleID")    # If bamFile does not exist in array add it
done


#Load modules
${stage} ${gatkVersion}

#Check modules
${checkStage}

echo "## "$(date)" Start $0"

  java -Xmx10g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
  -T HaplotypeCaller \
  -R ${indexFile} \
  ${inputs[@]} \
  --dbsnp ${dbsnpVcf}\
  -dontUseSoftClippedBases \
  -stand_call_conf 10.0 \
  -stand_emit_conf 20.0 \
  -o ${tmpGatkHaplotypeCallerGvcf} \
  -variant_index_type LINEAR \
  -variant_index_parameter 128000 \
  --emitRefConfidence GVCF



  mv ${tmpGatkHaplotypeCallerGvcf} ${GatkHaplotypeCallerGvcf}
  mv ${tmpGatkHaplotypeCallerGvcfidx} ${GatkHaplotypeCallerGvcfidx}
  echo "returncode: $?";
  echo "succes moving files";

  echo "## "$(date)" ##  $0 Done "
