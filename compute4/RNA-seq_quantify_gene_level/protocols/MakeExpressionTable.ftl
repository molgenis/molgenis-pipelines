#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

#FOREACH mergedStudy
mkdir -p ${expressionFolder}

rm -f ${expressionFolder}/fileList.txt

<#assign runs=run?size - 1>
<#list 0..runs as i>
  echo -e "${run[i]}\t${txtExpression[i]}" >> ${expressionFolder}/fileList.txt
</#list> 

if ${JAVA_HOME}/bin/java \
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
fi
