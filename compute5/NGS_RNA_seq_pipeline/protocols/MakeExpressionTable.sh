#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

#string expressionFolder 
#string processReadCountsJar
#string geneAnnotationTxt
#string expressionTable
#string project
#list externalSampleID

mkdir -p ${expressionFolder}

rm -f ${expressionFolder}/fileList.txt

for sample in "${externalSampleID[@]}" 
do
	inputs ${expressionFolder}/${sample}.htseq.txt
	echo -e "${sample}\t$expressionFolder/${sample}.htseq.txt" >> ${expressionFolder}/fileList.txt
done 

module load jdk
module list

if java \
        -Xmx4g \
        -jar ${processReadCountsJar} \
        --mode makeExpressionTable \
        --fileList ${expressionFolder}/fileList.txt \
        --annot ${geneAnnotationTxt} \
        --out ${expressionTable}___tmp___
then
        echo "table create succesfull"
        mv ${expressionTable}___tmp___ ${expressionTable}
else
        echo "table create failed"
	exit 1
fi
