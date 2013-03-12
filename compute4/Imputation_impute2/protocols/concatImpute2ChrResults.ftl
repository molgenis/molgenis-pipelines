#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr



declare -a impute2ChunkOutputs=(${ssvQuoted(impute2ChunkOutput)})
declare -a impute2ChunkOutputInfos=(${ssvQuoted(impute2ChunkOutputInfo)})

inputs ${ssvQuoted(impute2ChunkOutput)}
inputs ${ssvQuoted(impute2ChunkOutputInfo)}
chr="${chr}"

outputFolder="${outputFolder}"

<#noparse>

alloutputsexist "${outputFolder}/chr_${chr}" "${outputFolder}/chr_${chr}_info"

echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "impute2OutputFiles: ${impute2ChunkOutputs[@]}"
echo "impute2OutputInfoFiles: ${impute2ChunkOutputInfos[@]}"

mkdir -p $outputFolder

rm -f ${outputFolder}/~chr_${chr}
rm -f ${outputFolder}/chr_${chr}_info

#Concat the actual imputation results
cat ${impute2ChunkOutputs[@]} >> ${outputFolder}/~chr_${chr}

returnCode=$?
if [ $returnCode -eq 0 ]
then

	echo "Impute2 outputs concattenated"
	mv ${outputFolder}/~chr_${chr} ${outputFolder}/chr_${chr}

else
	echo "Failed to cat impute2 outputs to ${outputFolder}/~chr_${chr}" >&2
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
		head -n 1 < $chunkInfoFile >> ${outputFolder}/~chr_${chr}_info
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of info file ${chunkInfoFile} to ${outputFolder}/~chr_${chr}_info" >&2
			exit -1
		fi
		
		headerSet="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${outputFolder}/~chr_${chr}_info
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append info file ${chunkInfoFile} to ${outputFolder}/~chr_${chr}_info" >&2
		exit -1
	fi
	
done

echo "Impute2 output infos concattenated"
mv ${outputFolder}/~chr_${chr}_info ${outputFolder}/chr_${chr}_info

</#noparse>
