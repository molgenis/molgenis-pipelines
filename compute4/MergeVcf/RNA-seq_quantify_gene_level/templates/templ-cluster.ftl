#!/bin/bash
#PBS -q ${clusterqueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${memory}gb
#PBS -e ${location}/err/err_${scriptID}.err
#PBS -o ${location}/out/out_${scriptID}.out
mkdir -p ${location}/err
mkdir -p ${location}/out
printf "${scriptID}_started " >>${location}/log_${jobID}.txt
date "+DATE: %m/%d/%y%tTIME: %H:%M:%S" >>${location}/log_${jobID}.txt
date "+start time: %m/%d/%y%t %H:%M:%S" >>${location}/extra/${scriptID}.txt
echo running on node: `hostname` >>${location}/extra/${scriptID}.txt
${actualcommand}
${verificationcommand}
printf "${scriptID}_finished " >>${location}/log_${jobID}.txt
date "+finish time: %m/%d/%y%t %H:%M:%S" >>${location}/extra/${scriptID}.txt
date "+DATE: %m/%d/%y%tTIME: %H:%M:%S" >>${location}/log_${jobID}.txt 
