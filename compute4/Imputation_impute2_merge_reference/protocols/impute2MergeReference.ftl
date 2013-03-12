#MOLGENIS nodes=1 cores=1 mem=4

m="${m}"
h_ref0="${h_ref0}"
l_ref0="${l_ref0}"
h_ref1="${h_ref1}"
l_ref1="${l_ref1}"
additonalImpute2Param="${additonalImpute2Param}"
chr="${chr}"
fromChrPos="${fromChrPos}"
toChrPos="${toChrPos}"
imputationIntermediatesFolder="${imputationIntermediatesFolder}"
impute2Bin="${impute2Bin}"
panel1LegendFolder="${panel1LegendFolder}"

<#noparse>

startTime=$(date +%s)

echo "known_haps_g: ${known_haps_g}";
echo "chr: ${chr}"
echo "fromChrPos: ${fromChrPos}"
echo "toChrPos: ${toChrPos}"
echo "interMediFolder: ${imputationIntermediatesFolder}"

tmpOutput="${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}"
finalOutput="${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}"

echo "tmpOutput: ${tmpOutput}"

inputs $m
inputs $h_ref0
inputs $l_ref0
inputs $h_ref1
inputs $l_ref1

alloutputsexist \
	"${finalOutput}.legend" \
	"${finalOutput}.hap"

mkdir -p $imputationIntermediatesFolder
mkdir -p $panel1LegendFolder

awk '{print $1,$2,$3,$4}' < <(zcat $l_ref1) > ${panel1LegendFolder}/chr${chr}_${fromChrPos}-${toChrPos}.legend

$impute2Bin \
	-merge_ref_panels \
	-m $m \
	-h $h_ref0 $h_ref1 \
	-l $l_ref0 ${panel1LegendFolder}/chr${chr}_${fromChrPos}-${toChrPos}.legend \
	-int $fromChrPos $toChrPos \
	-merge_ref_panels_output_ref $tmpOutput \
	$additonalImpute2Param
		
#Get return code from last program call
returnCode=$?

echo "returnCode impute2: ${returnCode}"

if [ $returnCode -eq 0 ]
then

	#If there are no SNPs in this bin we will create empty files 
	if [ ! -f ${tmpOutput}_info ]
	then
		
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
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n" >&2
	#Return non zero return code
	exit 1

fi

endTime=$(date +%s)


#Source: http://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds-in-bash

num=$endTime-$startTime
min=0
hour=0
day=0
if((num>59));then
    ((sec=num%60))
    ((num=num/60))
    if((num>59));then
        ((min=num%60))
        ((num=num/60))
        if((num>23));then
            ((hour=num%24))
            ((day=num/24))
        else
            ((hour=num))
        fi
    else
        ((min=num))
    fi
else
    ((sec=num))
fi
echo "Running time: ${day} days ${hour} hours ${min} mins ${sec} secs"


</#noparse>