#MOLGENIS nodes=1 cores=1 mem=4G

#FOREACH project,chr

#Parameter mapping
#string project
#string chr
#string ImputeOutputFolder
#string samplechunksn
#list impute2SamplesMerged
#list impute2SamplesMergedInfo


declare -a impute2SamplesMerged=(${impute2SamplesMerged[@]})
declare -a impute2SamplesMergedInfo=(${impute2SamplesMergedInfo[@]})

echo "chr: ${chr}"
echo "ImputeOutputFolder: ${ImputeOutputFolder}"
echo "impute2SamplesMerged: ${impute2SamplesMerged[@]}"
echo "impute2SamplesMergedInfo: ${impute2SamplesMergedInfo[@]}"

alloutputsexist "${ImputeOutputFolder}/chr${chr}" "${ImputeOutputFolder}/chr${chr}_info"

for element in ${impute2SamplesMerged[@]}
do
    echo "Impute2 chuck: ${element}"
    getFile ${element}
    inputs ${element}
done

for element in ${impute2SamplesMergedInfo[@]}
do
    echo "Impute2 chuck info: ${element}"
    getFile ${element}
    inputs ${element}
done


mkdir -p ${ImputeOutputFolder}

rm -f ${ImputeOutputFolder}/~chr${chr}
rm -f ${ImputeOutputFolder}/~chr${chr}_info
rm -f ${ImputeOutputFolder}/chr${chr}
rm -f ${ImputeOutputFolder}/chr${chr}_info


#Make the array of the files
length_of_array=${#impute2SamplesMerged[@]}
length_of_array=$(($length_of_array-1))

declare -a impute2_samples_merged_files
declare -a impute2_samples_merged_info_files

for file_index in $(seq 0 $samplechunksn $length_of_array)
do
	impute2_samples_merged_files[$file_index]=${impute2SamplesMerged[$file_index]}
	impute2_samples_merged_info_files[$file_index]=${impute2SamplesMergedInfo[$file_index]}
done


#Concat the actual imputation results
toExecute="cat ${impute2_samples_merged_files[@]} >> ${ImputeOutputFolder}/~chr${chr}"

echo "Executing command: $toExecute"
eval ${toExecute}

returnCode=$?
if [ $returnCode -eq 0 ]
then

	echo "Impute2 outputs concattenated"
	mv ${ImputeOutputFolder}/~chr${chr} ${ImputeOutputFolder}/chr${chr}
	putFile ${ImputeOutputFolder}/chr${chr}

else
	echo "Failed to cat impute2 outputs to ${ImputeOutputFolder}/~chr${chr}" >&2
	exit -1
fi

#Need not capture the header of the first non empty file
headerSet="false"
for chunkInfoFile in "${impute2_samples_merged_info_files[@]}"
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
		head -n 1 < $chunkInfoFile >> ${ImputeOutputFolder}/~chr${chr}_info
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of info file ${chunkInfoFile} to ${ImputeOutputFolder}/~chr${chr}_info" >&2
			exit -1
		fi
		
		headerSet="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${ImputeOutputFolder}/~chr${chr}_info
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append info file ${chunkInfoFile} to ${ImputeOutputFolder}/~chr${chr}_info" >&2
		exit -1
	fi
	
done

echo "Impute2 output infos concattenated"
mv ${ImputeOutputFolder}/~chr${chr}_info ${ImputeOutputFolder}/chr${chr}_info
putFile ${ImputeOutputFolder}/chr${chr}_info
