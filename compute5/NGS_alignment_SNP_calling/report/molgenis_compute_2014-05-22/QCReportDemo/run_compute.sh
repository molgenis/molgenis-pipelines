# run compute
export ENVIRONMENT_DIR=rundir/
../molgenis_compute.sh -g -p parameters.csv -p parameters_qc.properties -header qc_header

# create QC-report
sh rundir/step_QC_0.sh

# open .md file