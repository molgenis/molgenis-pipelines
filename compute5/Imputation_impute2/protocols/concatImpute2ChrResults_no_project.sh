#MOLGENIS nodes=1 cores=1 mem=4G

#FOREACH chr

#Parameter mapping
#string project
#string chr
#string outputFolder
#list in_impute2ChunkOutput
#list in_impute2ChunkOutputInfo

declare -a impute2ChunkOutputs=(${in_impute2ChunkOutput[@]})
declare -a impute2ChunkOutputInfos=(${in_impute2ChunkOutputInfo[@]})

echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "impute2OutputFiles: ${impute2ChunkOutputs[@]}"
echo "impute2OutputInfoFiles: ${impute2ChunkOutputInfos[@]}"

for element in ${impute2ChunkOutputs[@]}
do
    echo "Impute2 chuck: ${element}"
    getFile ${element}
    inputs ${element}
done

for element in ${impute2ChunkOutputInfos[@]}
do
    echo "Impute2 chuck info: ${element}"
    getFile ${element}
    inputs ${element}
done

#Concat the actual imputation results
cat ${impute2ChunkOutputs[@]} >> ${outputFolder}/~chr${chr}

returnCode=$?
if [ $returnCode -eq 0 ]
then

	echo "Impute2 outputs concattenated"
	mv ${outputFolder}/~chr${chr} ${outputFolder}/chr${chr}
	putFile ${outputFolder}/chr${chr}

else
	echo "Failed to cat impute2 outputs to ${outputFolder}/~chr${chr}" >&2
	exit -1
fi

#Need not capture the header of the first non empty file
headerSet="false"
for chunkInfoFile in "${impute2ChunkOutputInfos[@]}"
do
	
	#Skip empty files
	lineCount=`wc -l ${chunkInfoFile} | awk '{print $1}'`
	echo "linecount ${lineCount} in: ${chunkInfoFile}"
	if [ "$lineCount" -eq "0" ]
	then
		echo "skipping empty info file: ${chunkInfoFile}" 
		continue
	fi

	#Print header if not yet done needed 
	if [ "$headerSet" == "false" ]
	then
		echo "print header from: ${chunkInfoFile}"
		head -n 1 < $chunkInfoFile >> ${outputFolder}/~chr${chr}_info
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of info file ${chunkInfoFile} to ${outputFolder}/~chr${chr}_info" >&2
			exit -1
		fi
		
		headerSet="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${outputFolder}/~chr${chr}_info
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append info file ${chunkInfoFile} to ${outputFolder}/~chr${chr}_info" >&2
		exit -1
	fi
	
done

echo "Impute2 output infos concattenated"
mv ${outputFolder}/~chr${chr}_info ${outputFolder}/chr${chr}_info
putFile ${outputFolder}/chr${chr}_info


