#MOLGENIS walltime=23:59:00 mem=12gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string picardVersion
#string markDuplicatesBam
#string markDuplicatesBai
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta
#string toolDir



${stage} picard/${picardVersion}
${checkStage}


mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" ##  $0 Started "


java -Xmx11g -XX:ParallelGCThreads=4 -jar $EBROOTPICARD/picard.jar CollectRnaSeqMetrics \
 INPUT=${markDuplicatesBam} \
 OUTPUT=${collectRnaSeqMetrics} \
 CHART_OUTPUT=${collectRnaSeqMetricsChart} \
 METRIC_ACCUMULATION_LEVEL=SAMPLE \
 METRIC_ACCUMULATION_LEVEL=READ_GROUP \
 REFERENCE_SEQUENCE=${onekgGenomeFasta} \
 REF_FLAT=${genesRefFlat} \
 RIBOSOMAL_INTERVALS=${rRnaIntervalList} \
 STRAND_SPECIFICITY=NONE \
 TMP_DIR=${collectRnaSeqMetricsDir} \
 
echo "returncode: $?";

cd ${collectRnaSeqMetricsDir}
md5sum $(basename ${collectRnaSeqMetrics}) > $(basename ${collectRnaSeqMetrics}).md5
md5sum $(basename ${collectRnaSeqMetricsChart}) > $(basename ${collectRnaSeqMetricsChart}).md5
echo "succes moving files";
cd -

echo "## "$(date)" ##  $0 Done "
