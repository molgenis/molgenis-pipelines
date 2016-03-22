#MOLGENIS walltime=23:59:00 mem=4gb ppn=1
# worksheet params:
#string project
#string logsDir
#list externalSampleID
#list lane
#list flowcell
#list batchID

# conststants
#string qcStatisticsCsv
#string project
#string logsDirQcDir
#string getStatisticsScript
#string getDedupInfoScript
#string qcStatisticsTex
#string qcStatisticsDescription
#string qcDedupMetricsOut
#string qcBaitSet
#string qcStatisticsTexReport
#string qcReportMD
#string allRawArrayTmpDataDir
#string intermediateDir
#string rVersion
#string inSilicoConcordanceFile
#string ngsversion
#string ngsUtilsVersion

module load ${rVersion}
module load ${ngsUtilsVersion}
module load ${ngsversion}

#
## Initialize
#
mkdir -p ${projectQcDir}
mkdir -p ${projectQcDir}/images

cp ${intermediateDir}/*.merged.dedup.bam.insert_size_histogram.pdf ${projectQcDir}/images

#
## Define bash helper function for arrays
#

function bashArrayToCSV {
        declare -a a=("${!1}")
        result="$(printf -- '%s,' "${a[@]}")"
        echo ${result:0:${#result}-1}
}

function bashArrayToString {
	declare -a a=("${!1}")
	echo "\"$(printf -- '%s;' "${a[@]}")\""
}

array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}


#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
for SampleID in "${externalSampleID[@]}"
do
        array_contains INPUTS "$SampleID" || INPUTS+=("$SampleID")    # If bamFile does not exist in array add it
done

#folded only on uniq externalSampleIDs
for sample in "${INPUTS[@]}"
do

	sampleHsMetrics+=("${intermediateDir}/${sample}.merged.dedup.bam.hs_metrics")
        sampleAlignmentMetrics+=("${intermediateDir}/${sample}.merged.dedup.bam.alignment_summary_metrics")
        sampleInsertMetrics+=("${intermediateDir}/${sample}.merged.dedup.bam.insert_size_metrics")
	sampleDedupMetrics+=("${intermediateDir}/${sample}.merged.dedup.metrics")
        sampleConcordance+=("${intermediateDir}/${sample}.concordance.ngsVSarray.txt")
        sampleInsertSizePDF+=("images/${sample}.merged.dedup.bam.insert_size_histogram.pdf")

done

#
## Gather QC statistics
#
# get general sample statistics
Rscript ${EBROOTNGSMINUTILS}/getStatistics/${getStatisticsScript} \
--hsmetrics $(bashArrayToCSV sampleHsMetrics[@]) \
--alignment $(bashArrayToCSV sampleAlignmentMetrics[@]) \
--insertmetrics $(bashArrayToCSV sampleInsertMetrics[@]) \
--dedupmetrics $(bashArrayToCSV sampleDedupMetrics[@]) \
--concordance $(bashArrayToCSV sampleConcordance[@]) \
--sample $(bashArrayToCSV INPUTS[@]) \
--colnames ${EBROOTNGSMINUTILS}/getStatistics/NiceColumnNames.csv \
--csvout ${qcStatisticsCsv} \
--tableout ${qcStatisticsTex} \
--descriptionout ${qcStatisticsDescription} \
--baitsetout ${qcBaitSet} \
--qcdedupmetricsout ${qcDedupMetricsOut} \
--precise

qcReportTemplate=${EBROOTNGS_DNA}/report/qc_report_template.Rmd
qcHelperFunctionsR=${EBROOTNGS_DNA}/report/knitr_helper_functions.R

count="0"
FIRSTLINE=""
SECONDLINE=""
thisSample=""

if [ -f ${qcDedupMetricsOut}.tmp ] 
then
	rm ${qcDedupMetricsOut}.tmp
fi

for i in $(ls ${intermediateDir}/*.merged.dedup.metrics)
do
        tail -1 ${i} | awk '{OFS="\n"} {print $1,$2}' >> ${qcDedupMetricsOut}.tmp
done

while read line
do
  	if [ $count == "0" ]
        then
            	FIRSTLINE+=$(echo "${line},")
                count="1"
        elif [ $count == "1" ]
        then
            	SECONDLINE+=$(echo "${line},")
                count="0"
        fi
done<${qcDedupMetricsOut}.tmp
FIRST=${FIRSTLINE%?}
SECOND=${SECONDLINE%?}

for sa in "${INPUTS[@]}"
do
  	thisSample+=$(echo "${sa},")
done

sam=${thisSample%?}
echo -e "Sample,${sam}" > ${qcDedupMetricsOut}
echo -e "READ_PAIR_DUPLICATES,${FIRST}\nPERCENT_DUPLICATION,${SECOND}" >> ${qcDedupMetricsOut}


#
## Run R script to knitr your report
#

	# NB you can ONLY export variables that are NOT an array (http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script)
	export user_env
	export qcStatisticsCsv
	export project
	export qcBaitSet
	export ngsversion
	export qcDedupMetricsOut
	export inSilicoConcordanceFile

R --slave <<RSCRIPT
	library(knitr)

	# load helpers
	source('${qcHelperFunctionsR}')

	# Keep template human-readable
	qcStatisticsCsv		= '${qcStatisticsCsv}'
	qcBaitSet 		= '${qcBaitSet}'
	projectQcDir		= '${projectQcDir}'
	qcReportTemplate	= '${qcReportTemplate}'
	qcReportMD		= '${qcReportMD}'
	ngsversion		= '${ngsversion}'
	qcDedupMetricsOut	= '${qcDedupMetricsOut}'
        externalSampleID        = stringToVector($(bashArrayToString externalSampleID[@]))
	sampleInsertSizePDF	= stringToVector($(bashArrayToString sampleInsertSizePDF[@]))
	inSilicoConcordanceFile	= '${inSilicoConcordanceFile}'

	setwd(projectQcDir) # because figs need to be next to output

	# knitr template
	knit(qcReportTemplate,qcReportMD)

RSCRIPT

