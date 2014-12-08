# worksheet params:
#string project
#list externalSampleID
#list lane
#list flowcell
#list chr

# conststants
#string qcStatisticsCsv
#string projectQcDir
#string qcReportTemplate
#string qcHelperFunctionsR
#string getStatisticsScript
#string getDedupInfoScript
#string qcStatisticsColNames
#string qcStatisticsTex
#string qcStatisticsDescription
#string qcDedupMetricsOut
#string qcBaitSet
#string qcStatisticsTexReport
#string qcReportMD
#string demultiplexStats
#string arrayDir
#string intermediateDir

module load R/3.0.2
module load molgenis_compute/v5_20140522
module list

#
## Initialize
#
mkdir -p ${projectQcDir}
mkdir -p ${projectQcDir}/images

cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.insert_size_histogram.pdf ${projectQcDir}/images

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

for sample in "${externalSampleID[@]}"
do 
	sampleHsMetrics+=("${intermediateDir}/${sample}.hs_metrics")
	sampleAlignmentMetrics+=("${intermediateDir}/${sample}.alignment_summary_metrics")
	sampleInsertMetrics+=("${intermediateDir}/${sample}.insert_size_metrics")
	sampleDedupMetrics+=("${intermediateDir}/${sample}.merged.dedup.metrics")
	sampleConcordance+=("${intermediateDir}/${sample}.concordance.ngsVSarray.txt")
	sampleInsertSizePDF+=("images/${sample}.merged.dedup.realigned.bqsr.bam.insert_size_histogram.pdf")
done


#
## Gather QC statistics
#
# get general sample statistics
Rscript ${getStatisticsScript} \
--hsmetrics $(bashArrayToCSV sampleHsMetrics[@]) \
--alignment $(bashArrayToCSV sampleAlignmentMetrics[@]) \
--insertmetrics $(bashArrayToCSV sampleInsertMetrics[@]) \
--dedupmetrics $(bashArrayToCSV sampleDedupMetrics[@]) \
--concordance $(bashArrayToCSV sampleConcordance[@]) \
--sample $(bashArrayToCSV externalSampleID[@]) \
--colnames ${qcStatisticsColNames} \
--csvout ${qcStatisticsCsv} \
--tableout ${qcStatisticsTex} \
--descriptionout ${qcStatisticsDescription} \
--baitsetout ${qcBaitSet} \
--qcdedupmetricsout ${qcDedupMetricsOut} \
--precise

# get dedup info per flowcell-lane-barcode/sample
Rscript ${getDedupInfoScript} \
--dedupmetrics $(bashArrayToCSV sampleDedupMetrics[@]) \
--flowcell $(bashArrayToCSV flowcell[@]) \
--lane $(bashArrayToCSV lane[@]) \
--sample $(bashArrayToCSV externalSampleID[@]) \
--paired TRUE \
--qcdedupmetricsout ${qcDedupMetricsOut}



#
## Run R script to knitr your report
#

	# NB you can ONLY export variables that are NOT an array (http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script)
	export user_env
	export qcStatisticsCsv
	export project
	export qcBaitSet
	export qcDedupMetricsOut

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

	setwd(projectQcDir) # because figs need to be next to output

	# knitr template
	knit(qcReportTemplate,qcReportMD)
	
RSCRIPT
