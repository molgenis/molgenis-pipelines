<#include "Helpers.ftl"/>
<#macro begin>
##### BEFORE #####
touch $PBS_O_WORKDIR/${jobname}.out
source ${importscript}
before="$(date +%s)"
echo "Begin job ${jobname} at $(date)" >> $PBS_O_WORKDIR/RUNTIME.log

echo Running on node: `hostname`

sleep 60
###### MAIN ######
</#macro>


<#macro end >
###### AFTER ######
after="$(date +%s)"
elapsed_seconds="$(expr $after - $before)"
echo Completed ${jobname} at $(date) in $elapsed_seconds seconds >> $PBS_O_WORKDIR/RUNTIME.log
touch $PBS_O_WORKDIR/${jobname}.finished
######## END ########
</#macro>

<#macro Rbegin>
${R} --vanilla <<RSCRIPT
</#macro>

<#macro Rend>
RSCRIPT
</#macro>