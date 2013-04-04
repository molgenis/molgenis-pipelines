#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr

getFile ${resultDir}/qc_1/chr${chr}.ped
getFile ${resultDir}/qc_1/chr${chr}.map

mkdir -p ${resultDir}/prunning

alloutputsexist \
    ${resultDir}/prunning/chr${chr}.ped
    ${resultDir}/prunning/chr${chr}.map

# http://pngu.mgh.harvard.edu/~purcell/plink/summary.shtml#prune
${plink} --file ${resultDir}/qc_1/chr${chr} --indep-pairwise 1000 5 0.2 --out ${resultDir}/prunning/~chr${chr} --noweb

${plink} --file ${resultDir}/qc_1/chr${chr} --extract ${resultDir}/prunning/~chr${chr}.prune.in --noweb --recode --out ${resultDir}/prunning/~chr${chr}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${resultDir}/prunning/~chr${chr}.ped ${resultDir}/prunning/chr${chr}.ped
    mv ${resultDir}/prunning/~chr${chr}.map ${resultDir}/prunning/chr${chr}.map

    putFile ${resultDir}/prunning/chr${chr}.ped
    putFile ${resultDir}/prunning/chr${chr}.map

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
