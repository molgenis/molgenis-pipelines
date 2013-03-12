#${jobname}
${jobname}=$(qsub -N ${jobname}${depend} ${jobname}.sh)
echo $${jobname}
sleep 8
