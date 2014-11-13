
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
taskId="step1_0"

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
in="ProjectNaam"

# Validate that each 'value' parameter has only identical values in its list
# We do that to protect you against parameter values that might not be correctly set at runtime.
if [[ ! $(IFS=$'\n' sort -u <<< "${in[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step1': input parameter 'in' is an array with different values. Maybe 'in' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi

#
## Start of your protocol template
#

#string in
#output out

# Let's do something with string 'in'
echo "${in}_hasBeenInStep1"
out=${in}_hasBeenInStep1

#
## End of your protocol template
#

# Save output in environment file: '$ENVIRONMENT_DIR/step1_0.env' with the output vars of this step
if [[ -z "$out" ]]; then echo "In step 'step1', parameter 'out' has no value! Please assign a value to parameter 'out'." >&2; exit 1; fi
echo "step1__has__out[0]=\"${out[0]}\"" >> $ENVIRONMENT_DIR/step1_0.env
echo "step1__has__out[1]=\"${out[1]}\"" >> $ENVIRONMENT_DIR/step1_0.env
echo "step1__has__out[2]=\"${out[2]}\"" >> $ENVIRONMENT_DIR/step1_0.env
echo "step1__has__out[3]=\"${out[3]}\"" >> $ENVIRONMENT_DIR/step1_0.env

echo "" >> $ENVIRONMENT_DIR/step1_0.env

