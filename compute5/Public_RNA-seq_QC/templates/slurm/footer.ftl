touch ${taskId}.sh.finished

echo "On $(date +"%Y-%m-%d %T"), after $(( ($(date +%s) - $MOLGENIS_START) / 60 )) minutes, task ${taskId} finished successfully" >> molgenis.bookkeeping.log
