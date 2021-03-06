#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string picardVersion
#string maskedBamSorted
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta
#string toolDir
#string RVersion

#Load module
${stage} picard/${picardVersion}
${stage} R/${RVersion}

#Check modules
${checkStage}

mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}picard/${picardVersion}/CollectRnaSeqMetrics.jar \
 INPUT=${maskedBamSorted} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir}

then
 echo "returncode: $?";
 putFile ${collectRnaSeqMetrics}
 putFile ${collectRnaSeqMetricsChart}
cd ${collectRnaSeqMetricsDir}
md5sum ${collectRnaSeqMetrics} > ${collectRnaSeqMetrics}.md5
md5sum ${collectRnaSeqMetricsChart} > ${collectRnaSeqMetricsChart}.md5
cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
