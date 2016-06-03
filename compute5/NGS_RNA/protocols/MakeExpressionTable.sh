#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=2gb

#string intermediateDir
#string processReadCountsJar
#list externalSampleID
#string geneAnnotationTxt
#string projectHTseqExpressionTable
#string project
#string jdkVersion
#string tmpTmpDataDir
#string groupname
#string tmpName

#Function to check if array contains value
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

makeTmpDir ${projectHTseqExpressionTable}
tmpProjectHTseqExpressionTable=${MC_tmpFile}

rm -f ${intermediateDir}/fileList.txt

INPUTS=()
for sample in "${externalSampleID[@]}"
do
	array_contains INPUTS "$sample" || INPUTS+=("$sample") 
done

for sampleID in "${INPUTS[@]}" 
do
	echo -e "${sampleID}\t$intermediateDir/${sampleID}.htseq.txt" >> ${intermediateDir}/fileList.txt
done 

module load ${jdkVersion}
module load ngs-utils
module list

	java -Xmx1g -XX:ParallelGCThreads=1 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTNGSMINUTILS}/${processReadCountsJar} \
        --mode makeExpressionTable \
        --fileList ${intermediateDir}/fileList.txt \
        --annot ${geneAnnotationTxt} \
        --out ${tmpProjectHTseqExpressionTable}

        echo "table create succesfull"
        mv ${tmpProjectHTseqExpressionTable} ${projectHTseqExpressionTable}

