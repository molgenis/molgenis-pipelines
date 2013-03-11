#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=4

known_haps_g="${known_haps_g}"
m="${m}"
h="${h}"
l="${l}"
additonalImpute2Param="${additonalImpute2Param}"
chr="${chr}"
fromChrPos="${fromChrPos}"
toChrPos="${toChrPos}"
imputationIntermediatesFolder="${imputationIntermediatesFolder}"
impute2Bin="${impute2Bin}"

<#noparse>

echo "known_haps_g: ${known_haps_g}";
echo "chr: ${chr}"
echo "fromChrPos: ${fromChrPos}"
echo "toChrPos: ${toChrPos}"
echo "interMediFolder: ${imputationIntermediatesFolder}"

tmpOutput="${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}"
finalOutput="${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}"

echo "tmpOutput: ${tmpOutput}"

inputs $m
inputs $h
inputs $l

alloutputsexist \
	"${finalOutput}" \
	"${finalOutput}_info" \
	"${finalOutput}_info_by_sample" \
	"${finalOutput}_summary" \
	"${finalOutput}_warnings"

mkdir -p $imputationIntermediatesFolder

$impute2Bin \
	-known_haps_g $known_haps_g \
	-m $m \
	-h $h \
	-l $l \
	-k_hap $k_hap \
	-int $fromChrPos $toChrPos \
	-o $tmpOutput \
	$additonalImpute2Param
		
#Get return code from last program call
returnCode=$?

echo "returnCode impute2 ${returnCode}"

if [ $returnCode -eq 0 ]
then

	#If there are no SNPs in this bin we will create empty files 
	if [ ! -f ${tmpOutput}_info ]
	then
	
		echo "Impute2 found not SNPs in this region. We now create empty output"
		echo "Touching file: ${tmpOutput}"
		echo "Touching file: ${tmpOutput}_info"
		echo "Touching file: ${tmpOutput}_info_by_sample"
	
		touch ${tmpOutput}
		touch ${tmpOutput}_info
		touch ${tmpOutput}_info_by_sample
	
	fi
	
		
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		mv $tempFile $finalFile
	done
	

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1

fi


</#noparse>