#job_${submitID}
job_${submitID}=$(qsub -N ${scriptID} ${dependancy} ${scriptID}.sh)
echo $job_${submitID}
sleep 8
