#MOLGENIS walltime=00:05:00 mem=4gb

#string GIANT_workDir

echo 'GIANT_workDir: ${GIANT_workDir}'

module load molgenis_compute/v5_20140522
module list

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

sh convert.sh ${MC_HOME}/GIANT_pipeline/parameters_not_converted.csv ${MC_HOME}/GIANT_pipeline/parameters.csv

GCC_HOME=/gcc
sh ${MC_HOME}/molgenis_compute.sh \
-p ${MC_HOME}/GIANT_pipeline/parameters.csv \
-w ${MC_HOME}/GIANT_pipeline/GIANT_workflow.csv \
-b pbs \
-rundir ${GIANT_workDir}/jobs \
--runid run01 \
--weave \
--generate

echo "creating jobs finished succesfully. You can now run ${GIANT_workDir}/jobs/submit.sh"
