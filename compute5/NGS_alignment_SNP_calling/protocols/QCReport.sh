#string project
#string qcStatisticsCsv
#string projectQcDir
#string qcReportTemplate
#string qcHelperFunctionsR

module load R/2.14.2
module list

#
## Initialize
#
mkdir  ${projectQcDir}

#
## Define bash helper function for arrays
#
function bashArrayToString {
	declare -a a=("${!1}")
	echo "\"$(printf -- '%s;' "${a[@]}")\""
}


#
## Gather QC statistics
#
# get general sample statistics
# Rscript ${getStatisticsScript} \
# --hsmetrics ${bashArrayToString(samplehsmetrics)} \
# --alignment ${bashArrayToString(samplealignmentmetrics)} \
# --insertmetrics ${bashArrayToString(sampleinsertsizemetrics)} \
# --dedupmetrics ${bashArrayToString(dedupmetrics)} \
# --concordance ${bashArrayToString(sampleconcordancefile)} \
# --sample ${bashArrayToString(externalSampleIDfolded)} \
# --colnames ${qcstatisticscolnames} \
# --csvout ${qcstatisticscsv} \
# --tableout ${qcstatisticstex} \
# --descriptionout ${qcstatisticsdescription} \
# --baitsetout ${qcbaitset} \
# --qcdedupmetricsout ${qcdedupmetricsout} \
# --precise


#
## Run R script to knitr your report
#

	# NB you can ONLY export variables that are NOT an array (http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script)
	export user_env
	export qcStatisticsCsv
	export project

R --slave <<RSCRIPT
	library(stringr)
	library(knitr)

	# load helpers
	source('${qcHelperFunctionsR}')
	
	# Make arrays available in R
	sample_nr = stringToVector($(bashArrayToString sample_nr[@]))
	sample_name = stringToVector($(bashArrayToString sample_name[@]))
	qc_coverage_plot_file = stringToVector($(bashArrayToString qc_coverage_plot_file[@]))

	# Keep template human-readable
	qcStatisticsCsv		= '${qcStatisticsCsv}'
	projectQcDir		= '${projectQcDir}'
	qcReportTemplate	= '${qcReportTemplate}'
	
	setwd(projectQcDir) # because figs need to be next to output

	# Show we can pass R-parameters!
	r.parameter = "content_of_r.parameter"

	# knitr template
	knit(qcReportTemplate)
	
RSCRIPT