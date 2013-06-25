#MOLGENIS walltime=2:00:00 nodes=1 cores=1 mem=4

#FOREACH projectDir
mkdir ${projectDir}/expression_table/

/cm/shared/apps/sunjdk/jdk1.6.0_21/bin/java \
-Xmx4g \
-jar ${processReadCountsJar} \
--mode makeExpressionTable \
--in ${mappedData} \
--pattern ${outPrefix}.flux.gtf \
--annot ${annotationTxt} \
--out ${expressionTable} \
--normalize false
