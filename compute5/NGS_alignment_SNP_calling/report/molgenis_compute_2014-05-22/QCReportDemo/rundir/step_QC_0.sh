
#
## convert bash array to R vector
#

function bashArrayToString {
	declare -a a=("${!1}")
	echo "\"$(printf -- '%s;' "${a[@]}")\""
}


#
## Generated header
#

# Assign values to the parameters in this script

# Set taskId, which is the job name of this task
taskId="step_QC_0"

# Make compute.properties available
rundir="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/rundir"
runid="bv8j"
workflow="./workflow.csv"
parameters="./parameters.csv,./parameters_qc.properties"
user="mdijkstra"
database="none"
backend="localhost"
port="8080"
interval="2000"
path="./"
# Load parameters from previous steps
source $ENVIRONMENT_DIR/user.env



# Connect parameters to environment
qc_helper_functions_R="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/protocols/knitr_helper_functions.R"
qc_csv="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/qcInputFiles/SCA_C_QCStatistics.csv"
qc_output_dir="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/qcOutputFiles"
user_env="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/rundir/user.env"
project="ProjectNaam"
qc_report_template="/Users/mdijkstra/Documents/git/molgenis-pipelines/compute5/NGS_alignment_SNP_calling/report/molgenis_compute_2014-05-22/QCReportDemo/protocols/qc_report_template.Rmd"
qc_coverage_plot_file[0]="../qcInputFiles/example_coverage_plot1.pdf"
qc_coverage_plot_file[1]="../qcInputFiles/example_coverage_plot2.pdf"
qc_coverage_plot_file[2]="../qcInputFiles/example_coverage_plot3.pdf"
qc_coverage_plot_file[3]="../qcInputFiles/example_coverage_plot4.pdf"
sample_nr[0]="1"
sample_nr[1]="2"
sample_nr[2]="3"
sample_nr[3]="4"

# Validate that each 'value' parameter has only identical values in its list
# We do that to protect you against parameter values that might not be correctly set at runtime.
if [[ ! $(IFS=$'\n' sort -u <<< "${qc_helper_functions_R[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'qc_helper_functions_R' is an array with different values. Maybe 'qc_helper_functions_R' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi
if [[ ! $(IFS=$'\n' sort -u <<< "${qc_csv[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'qc_csv' is an array with different values. Maybe 'qc_csv' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi
if [[ ! $(IFS=$'\n' sort -u <<< "${qc_output_dir[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'qc_output_dir' is an array with different values. Maybe 'qc_output_dir' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi
if [[ ! $(IFS=$'\n' sort -u <<< "${user_env[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'user_env' is an array with different values. Maybe 'user_env' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi
if [[ ! $(IFS=$'\n' sort -u <<< "${project[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'project' is an array with different values. Maybe 'project' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi
if [[ ! $(IFS=$'\n' sort -u <<< "${qc_report_template[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step_QC': input parameter 'qc_report_template' is an array with different values. Maybe 'qc_report_template' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi

#
## Start of your protocol template
#

#string project
#string qc_csv
#list sample_nr
#list qc_coverage_plot_file
#string user_env
#string qc_output_dir
#string qc_report_template
#string qc_helper_functions_R

#
## Initialize
#
mkdir  ${qc_output_dir}

#
## Run R script to knitr your report
#

# Does not work:
	#
	## First export the user.env for R knitr process
	#

	# Although it is possible to export _variables_, unfortunately it isn't possible to export _arrays_ (http://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script)
	#	Way to do this for variables: export $(cat ${user_env})
	# We have them available here, so we can make them R-variables, right away.
	# TODO: automate

	# NB you can ONLY export variables that are NOT an array
	export user_env
	export qc_csv
	export project

R --slave <<RSCRIPT
	library(stringr)
	library(knitr)

	# load helpers
	source('${qc_helper_functions_R}')
	
	# Make arrays available in R
	sample_nr = stringToVector($(bashArrayToString sample_nr[@]))
	sample_name = stringToVector($(bashArrayToString sample_name[@]))
	qc_coverage_plot_file = stringToVector($(bashArrayToString qc_coverage_plot_file[@]))

	# Keep template human-readable
	qc_csv				= '${qc_csv}'
	qc_output_dir		= '${qc_output_dir}'
	qc_report_template	= '${qc_report_template}'
	
	setwd(qc_output_dir) # because figs need to be next to output

	# Show we can pass R-parameters!
	r.parameter = "content_of_r.parameter"

	# knitr template
	knit(qc_report_template)
	
RSCRIPT

#
## End of your protocol template
#

# Save output in environment file: '$ENVIRONMENT_DIR/step_QC_0.env' with the output vars of this step

echo "" >> $ENVIRONMENT_DIR/step_QC_0.env

