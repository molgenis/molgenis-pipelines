#
## General footer
#

# Show that we successfully finished
# If this file exists, then this step will be skipped when you resubmit your workflow 
touch $ENVIRONMENT_DIR/${taskId}.sh.finished

echo "On $(date +"%Y-%m-%d %T"), after $(( ($(date +%s) - $MOLGENIS_START) / 60 )) minutes, task ${taskId} finished successfully" >> $ENVIRONMENT_DIR/molgenis.bookkeeping.log

<#noparse>
if [ -d ${MC_tmpFolder:-} ];</#noparse>
	then
	echo "removed tmpFolder $MC_tmpFolder"
	rm -r $MC_tmpFolder
fi
