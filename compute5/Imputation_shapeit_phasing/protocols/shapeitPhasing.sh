#MOLGENIS nodes=1 cores=8 mem=2G

#foreach project,chr

#Parameter mapping
#string shapeitBin
#string m
#string studyData
#string studyDataType
#string shapeitThreads
#string chr
#string outputFolder
#string stage
#string shapeitversion



tmpOutput="${outputFolder}/~chr${chr}"
finalOutput="${outputFolder}/chr${chr}"



if [ "${stage}" != "" ]
then
	${stage} shapeit/${shapeitversion}
fi



echo "m: ${m}";
echo "studyData: ${studyData}"
echo "studyDataType: ${studyDataType}"
echo "shapeitThreads: ${shapeitThreads}"
echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "tmpOutput: ${tmpOutput}"

echo "test1"

mkdir -p ${outputFolder}

if [ $studyDataType == "PED" ]; then
	inputVarName="--input-ped"
elif [ $studyDataType == "BED" ]; then
	inputVarName="--input-bed"
elif [ $studyDataType == "GEN" ]; then
	inputVarName="--input-gen"
else
  	echo "The variable studyDataType provided in the worksheet does not match any of the following values: PED, BED or GEN"
  	echo "Analysis can not be continued. Exiting now!"
  	exit 1
fi

echo "test2"

startTime=$(date +%s)

alloutputsexist \
	"${outputFolder}/chr${chr}.haps" \
	"${outputFolder}/chr${chr}.sample"

getFile $m
inputs $m

echo "test3"

# $studyData can be multiple files. Here we will check each file and do a getFile, if needed, for each file
for studyDataFile in $studyData
do
	echo "Study data file detected: ${studyDataFile}"
	getFile $studyDataFile
	inputs $studyDataFile
done


echo "test4" 

if $shapeitBin \
	$inputVarName $studyData \
	--input-map $m \
	--output-max $tmpOutput \
	--thread $shapeitThreads \
	--output-log ${tmpOutput}.log
then
	#Command successful
	echo "returnCode ShapeIt2: $?"
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
		putFile $finalFile
	done
	
else 
	#Command failed
	echo "returncode ShapeIt2: $?"
	
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



