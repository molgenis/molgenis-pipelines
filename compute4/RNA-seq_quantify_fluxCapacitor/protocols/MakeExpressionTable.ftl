#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=4

#FOREACH mergedStudy
mkdir -p ${expressionFolder}

rm -f ${expressionFolder}/fileList.txt

<#assign samples=sample?size - 1>
<#list 0..samples as i>
  echo -e "${sample[i]}\t${gtfExpression[i]}" >> ${expressionFolder}/fileList.txt
</#list> 

${JAVA_HOME}/bin/java \
	-Xmx4g \
	-jar ${processReadCountsJar} \
	--mode makeExpressionTable \
	--fileList ${expressionFolder}/fileList.txt \
	--annot ${annotationTxt} \
	--out ${expressionTable}

