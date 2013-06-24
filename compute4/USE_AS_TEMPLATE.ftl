#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4



getFile ${referenceImpute2HapFile}
getFile ${referenceImpute2LegendFile}
getFile ${referenceImpute2MapFile}
getFile ${preparedStudyDir}/chr${chr}.gen
putFile ${impute2ResultChrBin}
putFile ${impute2ResultChrBin}_info
putFile ${impute2ResultChrBin}_info_by_sample
putFile ${impute2ResultChrBin}_summary
putFile ${impute2ResultChrBin}_warnings


inputs "${referenceImpute2HapFile}"
inputs "${referenceImpute2LegendFile}"
inputs "${referenceImpute2MapFile}"
inputs "${preparedStudyDir}/chr${chr}.gen"
inputs "${impute2ResultChrBin}"
inputs "${impute2ResultChrBin}_info"
inputs "${impute2ResultChrBin}_info_by_sample"
inputs "${impute2ResultChrBin}_summary"
inputs "${impute2ResultChrBin}_warnings"

module load ${impute}/${impute2Binversion}

mkdir -p ${impute2ResultDir}/${chr}/

${impute2Bin} -h ${referenceImpute2HapFile} -l ${referenceImpute2LegendFile} -m ${referenceImpute2MapFile} -g ${preparedStudyDir}/chr${chr}.gen -int ${fromChrPos} ${toChrPos} -o ${impute2ResultChrBinTemp}


#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in ${impute2ResultChrBinTemp}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi