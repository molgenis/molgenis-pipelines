#MOLGENIS nodes=1 cores=1 mem=4G

#FOREACH project,chr

#Parameter mapping
#string project
#string chr
#string outputFolder
#string imputationIntermediatesFolder
#string fromChrPos
#string toChrPos
#list impute2ChunkOutput
#list impute2ChunkOutputInfo

#output impute2SamplesMerged
#output impute2SamplesMergedInfo

#declare -a impute2ChunkOutputs=(${ssvQuoted(impute2ChunkOutput)})
#declare -a impute2ChunkOutputInfos=(${ssvQuoted(impute2ChunkOutputInfo)})

declare -a impute2ChunkOutputs=(${impute2ChunkOutput[@]})
declare -a impute2ChunkOutputInfos=(${impute2ChunkOutputInfo[@]})

declare -a imputation__has__impute2ChunkOutputInfo=(${imputation__has__impute2ChunkOutputInfo[@]})
declare -a imputation__has__impute2ChunkOutput=(${imputation__has__impute2ChunkOutput[@]})


echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "imputationIntermediatesFolder: ${imputationIntermediatesFolder}"
echo "imputation__has__impute2ChunkOutput: ${imputation__has__impute2ChunkOutput[@]}"
echo "imputation__has__impute2ChunkOutputInfo: ${imputation__has__impute2ChunkOutputInfo[@]}"

impute2SamplesMerged=${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}
impute2SamplesMergedInfo=${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_info

alloutputsexist "${imputationIntermediatesFolder}/chr${chr}_$fromChrPos{}-${toChrPos}" "${imputationIntermediatesFolder}/chr${chr}_$fromChrPos{}-${toChrPos}_info"

for element in ${imputation__has__impute2ChunkOutput[@]}
do
    echo "Impute2 chunc: ${element}"
    getFile ${element}
    inputs ${element}
done

for element in ${imputation__has__impute2ChunkOutputInfo[@]}
do
    echo "Impute2 info: ${element}"
    getFile ${element}
    inputs ${element}
done

mkdir -p ${imputationIntermediatesFolder}

rm -f ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}
rm -f ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}
rm -f ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}_info
rm -f ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_info

#Merging chunks
toExecute="paste <(cut -d ' ' -f 1-5 ${imputation__has__impute2ChunkOutput[0]})"
for element in ${imputation__has__impute2ChunkOutput[@]}
do
	toExecute="${toExecute} <( cut -d ' ' -f 6- ${element} )"
done
toExecute="${toExecute} > ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}"

echo "Executing: $toExecute"
eval ${toExecute}


returnCode=$?
if [ $returnCode -eq 0 ]
then

	echo "Impute2 outputs concatenated for ${fromChrPos}-${toChrPos}"
	mv ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos} ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}
	putFile ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}

else
	echo "Failed to cat impute2 outputs to ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}" >&2
	exit -1
fi


#Merging infos (simple vertical merging)
toExecute="paste ${imputation__has__impute2ChunkOutputInfo[@]} > ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}_info"
echo "Executing: ${toExecute}"
eval ${toExecute}

returnCode=$?
if [ $returnCode -eq 0 ]
then

        echo "Impute2 infos concatenated for ${fromChrPos}-${toChrPos}"
        mv ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}_info ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_info
        putFile ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_info

else
        echo "Failed to cat impute2 outputs to ${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}_info" >&2
        exit -1
fi

