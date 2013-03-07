#!/bin/bash
#PBS -N ${jobname}
#PBS -q ${clusterQueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${jobname}.err
#PBS -o ${jobname}.out

<#if bashrc?? && bashrc != "">
# Configures the bash environment.
. ${bashrc}
</#if>

<#-- Include workflow specific header, if any. -->
<#if workflowHeader?? && workflowHeader != "">
<#include "${workflowHeader}" />
</#if>

<#include "Macros.ftl"/>

##### BEFORE #####
touch $PBS_O_WORKDIR/${jobname}.out
#source {importscript}
before="$(date +%s)"
echo "Begin job ${jobname} at $(date)" >> $PBS_O_WORKDIR/RUNTIME.log

echo Running on node: `hostname`

###### MAIN ######

<#if defaultInterpreter = "R"><@Rbegin/></#if>