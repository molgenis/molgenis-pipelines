#!/bin/bash
#PBS -N ${jobname}
#PBS -q ${clusterQueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${outputFolder}/${jobname}.err
#PBS -o ${outputFolder}/${jobname}.out
#PBS -W umask=0007

# Configures the GCC bash environment
. ${root}/gcc.bashrc

