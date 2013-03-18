#MOLGENIS nodes=1 cores=1 mem=4

#FOREACH project,chr



declare -a impute2ChunkOutputHaps=(${ssvQuoted(impute2ChunkOutputHap)})
declare -a impute2ChunkOutputLegends=(${ssvQuoted(impute2ChunkOutputLegend)})

inputs ${ssvQuoted(impute2ChunkOutputHap)}
inputs ${ssvQuoted(impute2ChunkOutputLegend)}
chr="${chr}"

outputFolder="${outputFolder}"

<#noparse>

alloutputsexist "${outputFolder}/chr${chr}.hap.gz" "${outputFolder}/chr${chr}.legend.gz"

echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "impute2OutputHapFiles: ${impute2ChunkOutputHaps[@]}"
echo "impute2OutputLegendFiles: ${impute2ChunkOutputLegends[@]}"

mkdir -p $outputFolder

rm -f ${outputFolder}/~chr${chr}.hap
rm -f ${outputFolder}/~chr${chr}.legend
rm -f ${outputFolder}/~chr${chr}.hap.gz
rm -f ${outputFolder}/~chr${chr}.legend.gz
rm -f ${outputFolder}/chr${chr}.hap.gz
rm -f ${outputFolder}/chr${chr}.legend.gz

#Concat the actual imputation results
cat ${impute2ChunkOutputHaps[@]} >> ${outputFolder}/~chr${chr}.hap

returnCode=$?
if [ $returnCode -eq 0 ]
then

	gzip -c < ${outputFolder}/~chr${chr}.hap > ${outputFolder}/~chr${chr}.hap.gz
	
	returnCode=$?
	if [ $returnCode -eq 0 ]
	then
		echo "combined ref hap files concattenated"
		mv  ${outputFolder}/~chr${chr}.hap.gz ${outputFolder}/chr${chr}.hap.gz
	else
		echo "Failed to gzip hap to ${outputFolder}/~chr${chr}.hap.gz" >&2
		exit -1
	fi
	
else
	echo "Failed to cat combined ref hap files to ${outputFolder}/~chr${chr}.hap" >&2
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
		echo "skipping empty legend file: ${chunkInfoFile}" 
		continue
	fi

	#Print header if not yet done needed 
	if [ "$headerSet" == "false" ]
	then
		echo "print header from: ${chunkInfoFile}"
		head -n 1 < $chunkInfoFile >> ${outputFolder}/~chr${chr}.legend
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of legend file ${chunkInfoFile} to ${outputFolder}/~chr${chr}.legend" >&2
			exit -1
		fi
		
		headerSet="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${outputFolder}/~chr${chr}.legend
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append legend file ${chunkInfoFile} to ${outputFolder}/~chr${chr}.legend" >&2
		exit -1
	fi
	
done

gzip -c <${outputFolder}/~chr${chr}.legend > ${outputFolder}/~chr${chr}.legend.gz
returnCode=$?
if [ $returnCode -eq 0 ]
then
	echo "Impute2 combined ref legend files concattenated"
	mv ${outputFolder}/~chr${chr}.legend.gz ${outputFolder}/chr${chr}.legend.gz
else
	echo "Failed to gzip legend to ${outputFolder}/~chr${chr}.legend.gz" >&2
	exit -1
fi



</#noparse>
