#MOLGENIS walltime=6:00:00 nodes=1 cores=1 mem=4

#FOREACH mergedStudy

mkdir -p ${mappingStatisticsFolder}
rm -f ${fileList}

<#assign samples=sample?size - 1>
<#list 0..samples as i>
  echo -e "${sample[i]}\t${STARlogFile[i]}" >> ${fileList}
</#list> 

${mappingStatisticsScript} \
	-f ${fileList} \
	> ${mappingStatistics}

