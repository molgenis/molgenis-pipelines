#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,studyInputDir,resultDir,removeDir


getFile ${studyInputDir}/merged.ped
getFile ${studyInputDir}/merged.map
getFile ${removeDir}/indv_to_exclude

mkdir -p ${resultDir}

alloutputsexist \
  ${resultDir}/merged.ped \
  ${resultDir}/merged.map

${plink} --file ${studyInputDir}/merged --remove ${removeDir}/indv_to_exclude --noweb --recode --out ${resultDir}/~merged

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	mv ${resultDir}/~merged.ped ${resultDir}/merged.ped
	mv ${resultDir}/~merged.map ${resultDir}/merged.map

	putFile ${resultDir}/merged.ped
	putFile ${resultDir}/merged.map

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1
fi

