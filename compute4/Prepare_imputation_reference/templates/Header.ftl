<#if scheduler == "PBS">
#!/bin/bash
#PBS -N ${jobname}
#PBS -q ${clusterQueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${jobname}.err
#PBS -o ${jobname}.out

<#elseif scheduler == "SGE">
#!/bin/bash
#$ -N ${jobname}
#$ -q ${clusterQueue}
#$ -p ${cores}
#$ -l h_rt=${walltime}
#$ -l h_vmem=${mem}
#$ -e ${jobname}.err
#$ -o ${jobname}.out

</#if>



# Configures the GCC bash environment
. ${root}/gcc.bashrc

<#include "Macros.ftl"/>
<@begin/>

<#if defaultInterpreter = "R"><@Rbegin/></#if>