#MOLGENIS walltime=35:59:00 mem=4gb nodes=1 ppn=1

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string intermediateDir

#string picardVersion

#string markDuplicatesBam
#string markDuplicatesBai
#string collectRnaSeqMetricsDir
#string collectRnaSeqMetrics
#string collectRnaSeqMetricsChart
#string genesRefFlat
#string rRnaIntervalList
#string onekgGenomeFasta


alloutputsexist \
 ${collectRnaSeqMetrics} \
 ${collectRnaSeqMetricsChart}

getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}

${stage} picard-tools/${picardVersion}
${checkStage}

mkdir -p ${collectRnaSeqMetricsDir}

echo "## "$(date)" ##  $0 Started "

java -Xmx4g -jar $PICARD_HOME/CollectRnaSeqMetrics.jar \
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
 

putFile ${collectRnaSeqMetrics}
putFile ${collectRnaSeqMetricsChart}

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
