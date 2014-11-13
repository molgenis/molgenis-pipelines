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