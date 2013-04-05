#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr

getFile ${studyInputDir}/chr${chr}.ped
getFile ${studyInputDir}/chr${chr}.map

mkdir -p ${resultDir}

alloutputsexist \
    ${resultDir}/chr${chr}.ped
    ${resultDir}/chr${chr}.map

# http://pngu.mgh.harvard.edu/~purcell/plink/summary.shtml#prune
${plink} --file ${studyInputDir}/chr${chr} --indep-pairwise 1000 5 0.2 --out ${resultDir}/~chr${chr} --noweb

${plink} --file ${studyInputDir}/chr${chr} --extract ${resultDir}/~chr${chr}.prune.in --noweb --recode --out ${resultDir}/~chr${chr}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${resultDir}/~chr${chr}.ped ${resultDir}/chr${chr}.ped
    mv ${resultDir}/~chr${chr}.map ${resultDir}/chr${chr}.map

    putFile ${resultDir}/chr${chr}.ped
    putFile ${resultDir}/chr${chr}.map

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
