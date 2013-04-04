#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project


getFile ${studyInputDir}/merged.bed
getFile ${studyInputDir}/merged.bim
getFile ${studyInputDir}/merged.fam

mkdir -p ${resultDir}

alloutputsexist \
  ${resultDir}/merged.kin

${king} -b ${studyInputDir}/merged.bed --kinship --related --prefix ${resultDir}/~merged

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	mv ${resultDir}/~merged.kin ${resultDir}/merged.kin

	putFile ${resultDir}/merged.kin

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
