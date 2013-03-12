#MOLGENIS nodes=1 cores=1 mem=4

#FOREACH project,chr



declare -a impute2ChunkOutputHaps=(${ssvQuoted(impute2ChunkOutputHap)})
declare -a impute2ChunkOutputLegends=(${ssvQuoted(impute2ChunkOutputLegend)})

inputs ${ssvQuoted(impute2ChunkOutputHap)}
inputs ${ssvQuoted(impute2ChunkOutputLegend)}
chr="${chr}"

outputFolder="${outputFolder}"

<#noparse>

alloutputsexist "${outputFolder}/chr${chr}_hap" "${outputFolder}/chr${chr}_legend"

echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "impute2OutputFiles: ${impute2ChunkOutputHaps[@]}"
echo "impute2OutputInfoFiles: ${impute2ChunkOutputLegends[@]}"

mkdir -p $outputFolder

rm -f ${outputFolder}/~chr${chr}_hap
rm -f ${outputFolder}/~chr${chr}_legend
rm -f ${outputFolder}/chr${chr}_hap
rm -f ${outputFolder}/chr${chr}_legend

#Concat the actual imputation results
cat ${impute2ChunkOutputHaps[@]} >> ${outputFolder}/~chr${chr}_hap

returnCode=$?
if [ $returnCode -eq 0 ]
then

	echo "Impute2 outputs concattenated"
	mv ${outputFolder}/~chr${chr}_hap ${outputFolder}/chr${chr}_hap

else
	echo "Failed to cat impute2 outputs to ${outputFolder}/~chr${chr}_hap" >&2
	exit -1
fi

#Need not capture the header of the first non empty file
headerSet="false"
for chunkInfoFile in "${impute2ChunkOutputLegends[@]}"
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
		head -n 1 < $chunkInfoFile >> ${outputFolder}/~chr${chr}_legend
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of info file ${chunkInfoFile} to ${outputFolder}/~chr${chr}_legend" >&2
			exit -1
		fi
		
		headerSet="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${outputFolder}/~chr${chr}_legend
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append info file ${chunkInfoFile} to ${outputFolder}/~chr${chr}_legend" >&2
		exit -1
	fi
	
done

echo "Impute2 output infos concattenated"
mv ${outputFolder}/~chr${chr}_legend ${outputFolder}/chr${chr}_legend

</#noparse>
