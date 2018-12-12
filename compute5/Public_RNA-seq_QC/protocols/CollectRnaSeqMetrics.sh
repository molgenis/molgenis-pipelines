#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
#string uniqueID
###
#string stage
#string checkStage
#string picardVersion
#string sortedBam
#string sortedBai
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

java -Xmx8g -XX:ParallelGCThreads=4 -jar $EBROOTPICARD/picard.jar CollectRnaSeqMetrics \
 INPUT=${sortedBam} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir}

echo "returncode: $?";

cd ${collectRnaSeqMetricsDir}
md5sum $(basename ${collectRnaSeqMetrics}) > $(basename ${collectRnaSeqMetrics}).md5
md5sum $(basename ${collectRnaSeqMetricsChart}) > $(basename ${collectRnaSeqMetricsChart}).md5
cd -

echo "## "$(date)" ##  $0 Done "
