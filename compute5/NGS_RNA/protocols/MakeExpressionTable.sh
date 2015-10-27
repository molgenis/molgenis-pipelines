#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

#string intermediateDir
#string processReadCountsJar
#string geneAnnotationTxt
#string expressionTable
#string project
#string jdkVersion
#list externalSampleID

rm -f ${intermediateDir}/fileList.txt

for sample in "${externalSampleID[@]}" 
do
	inputs ${intermediateDir}/${sample}.htseq.txt
	echo -e "${sample}\t$intermediateDir/${sample}.htseq.txt" >> ${intermediateDir}/fileList.txt
done 

module load jdk/${jdkVersion}
module list

if java \
        -Xmx4g \
        -jar ${processReadCountsJar} \
        --mode makeExpressionTable \
        --fileList ${intermediateDir}/fileList.txt \
        --annot ${geneAnnotationTxt} \
        --out ${expressionTable}___tmp___
then
        echo "table create succesfull"
        mv ${expressionTable}___tmp___ ${expressionTable}
else
        echo "table create failed"
	exit 1
fi
