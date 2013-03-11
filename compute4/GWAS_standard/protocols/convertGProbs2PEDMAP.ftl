#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

getFile ${resultsDir}/OUTPUT.gprobs
getFile ${tooldir}/python_scripts/convertGProbs2PEDMAP.py

module load Python/2.7.3
python -V

python ${tooldir}/python_scripts/convertGProbs2PEDMAP.py ${resultsDir}/OUTPUT.gprobs ${aposterioriThreshold} ${chr} ${resultsDir}/OUTPUT_${aposterioriThreshold}.tped

putFile ${resultsDir}/OUTPUT_${aposterioriThreshold}.tped

