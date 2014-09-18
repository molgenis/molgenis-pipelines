<#if scheduler == "PBS">
#!/bin/bash
#PBS -N ${jobname}
#PBS -q ${clusterQueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${jobname}.err
#PBS -o ${jobname}.out
#PBS -W umask=0007

<#elseif scheduler == "SGE">
#!/bin/bash
#$ -N ${jobname}
#$ -q ${clusterQueue}
#$ -pe smp ${cores}
#$ -l h_rt=${walltime}
#$ -l mem_free=${mem}
#$ -e ${jobname}.err
#$ -o ${jobname}.out

<#elseif scheduler == "BSUB">
#!/bin/bash
#BSUB -J ${jobname}
#BSUB -q ${clusterQueue}
#BSUB -C ${cores}
#BSUB -c ${walltime}
#BSUB -M ${mem}
#BSUB -e ${jobname}.err
#BSUB -o ${jobname}.out

<#elseif scheduler == "GRID">

</#if>

# Source functions for data transfer to cluster
source dataTransfer.sh

<#if scheduler != "GRID">
# Configures the GCC bash environment
source ${root}/gcc.bashrc
</#if>

<#include "Macros.ftl"/>
<@begin/>
<#include "NGSHeader.ftl"/>
<#if defaultInterpreter = "R"><@Rbegin/></#if>