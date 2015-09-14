#MOLGENIS walltime=23:59:00 mem=4gb ppn=1
# worksheet params:
#string project
#list externalSampleID
#list lane
#list flowcell
#list batchID

# conststants
#string qcStatisticsCsv
#string projectQcDir
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
#string pathToNGSBetaVersion
#string ngsDNAVersion

module load ${rVersion}
module load ngs-utils
module load ${ngsDNAVersion}

#
## Initialize
#
mkdir -p ${projectQcDir}
mkdir -p ${projectQcDir}/images

cp ${intermediateDir}/*.merged.dedup.realigned.bam.insert_size_histogram.pdf ${projectQcDir}/images

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

	sampleHsMetrics+=("${intermediateDir}/${sample}.merged.dedup.realigned.bam.hs_metrics")
        sampleAlignmentMetrics+=("${intermediateDir}/${sample}.merged.dedup.realigned.bam.alignment_summary_metrics")
        sampleInsertMetrics+=("${intermediateDir}/${sample}.merged.dedup.realigned.bam.insert_size_metrics")
	sampleDedupMetrics_folded+=("${intermediateDir}/${sample}.merged.dedup.metrics")
        sampleConcordance+=("${intermediateDir}/${sample}.concordance.ngsVSarray.txt")
        sampleInsertSizePDF+=("images/${sample}.merged.dedup.realigned.bam.insert_size_histogram.pdf")

done

#unfolded dor dedupMatrics per lane,flowcell.
for sample in "${externalSampleID[@]}"
do 
	sampleDedupMetrics+=("${intermediateDir}/${sample}.merged.dedup.metrics")
done


#
## Gather QC statistics
#
# get general sample statistics
Rscript ${EBROOTNGSMINUTILS}/getStatistics/${getStatisticsScript} \
--hsmetrics $(bashArrayToCSV sampleHsMetrics[@]) \
--alignment $(bashArrayToCSV sampleAlignmentMetrics[@]) \
--insertmetrics $(bashArrayToCSV sampleInsertMetrics[@]) \
--dedupmetrics $(bashArrayToCSV sampleDedupMetrics_folded[@]) \
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

#
## Run R script to knitr your report
#

	# NB you can ONLY export variables that are NOT an array (http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script)
	export user_env
	export qcStatisticsCsv
	export project
	export qcBaitSet
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
	qcDedupMetricsOut	= '${qcDedupMetricsOut}'
        externalSampleID        = stringToVector($(bashArrayToString externalSampleID[@]))
	sampleInsertSizePDF	= stringToVector($(bashArrayToString sampleInsertSizePDF[@]))
	inSilicoConcordanceFile	= '${inSilicoConcordanceFile}'

	setwd(projectQcDir) # because figs need to be next to output

	# knitr template
	knit(qcReportTemplate,qcReportMD)

RSCRIPT

