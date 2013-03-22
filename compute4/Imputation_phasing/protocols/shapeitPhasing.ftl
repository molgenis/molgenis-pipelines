#MOLGENIS nodes=1 cores=8 mem=2

foreach project,chr

mkdir -p ${phasingIntermediatesFolder}

shapeitBin = "${shapeitGridBin}"
m="${m}"
studyPedMap="${studyPedMap}"
threads="${shapeitThreads}"
chr="${chr}"

tmpOutput="${phasingIntermediatesFolder}/~chr${chr}"
finalOutput="${phasingIntermediatesFolder}/chr${chr}"


getFile ${m}

#Split variable studyPedMap on spaces
INSPM="${studyPedMap}"
arr1=$(echo $INSPM | tr " " "\n")

for element in $arr1
do
    echo "Detected files: $element"
    getFile $element
done

${stage} shapeit/${shapeitversion}



startTime=$(date +%s)

echo "m: ${m}";
echo "studyPedMap: ${studyPedMap}"
echo "threads: ${shapeitThreads}"
echo "chr: ${chr}"
echo "interMediFolder: ${phasingIntermediatesFolder}"

echo "tmpOutput: ${tmpOutput}"

<#noparse>

$shapeitBin \
--input-ped $studyPedMap \
--input-map $m \
--output-max $tmpOutput \
--thread $threads


#Get return code from last program call
returnCode=$?

echo "returnCode shapeIt: ${returnCode}"

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		mv $tempFile $finalFile
		putFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
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