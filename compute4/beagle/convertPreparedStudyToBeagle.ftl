#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

#INPUTS ${preparedStudyDir}/chr${chr}.dat,${preparedStudyDir}/chr${chr}.ped
#OUTPUTS ${preparedStudyDir}/chr${chr}.bgl
#EXES ${linkage2beagle}
#LOGS log
#TARGETS project,chr,batch

#FOREACH project,chr,batch

inputs "${preparedStudyDir}/chr${chr}.dat"
inputs "${preparedStudyDir}/chr${chr}-${batch}.ped"
alloutputsexist "${preparedStudyDir}/chr${chr}-${batch}.bgl"

java -jar ${linkage2beagle} ${preparedStudyDir}/chr${chr}.dat ${preparedStudyDir}/chr${chr}-${batch}.ped > ${preparedStudyDir}/chr${chr}-${batch}.bgl

sleep 30
