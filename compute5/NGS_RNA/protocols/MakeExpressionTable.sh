#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

#string intermediateDir
#string processReadCountsJar
#list externalSampleID
#string geneAnnotationTxt
#string projectHTseqEexpressionTable
#string project
#string jdkVersion

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

makeTmpDir ${projectHTseqEexpressionTable}
tmpProjectHTseqEexpressionTable=${MC_tmpFile}

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

module load jdk/${jdkVersion}
module list

if java \
        -Xmx4g \
        -jar ${processReadCountsJar} \
        --mode makeExpressionTable \
        --fileList ${intermediateDir}/fileList.txt \
        --annot ${geneAnnotationTxt} \
        --out ${tmpProjectHTseqEexpressionTable}
then
        echo "table create succesfull"
        mv ${tmpProjectHTseqEexpressionTable} ${projectHTseqEexpressionTable}
else
        echo "table create failed"
	exit 1
fi
