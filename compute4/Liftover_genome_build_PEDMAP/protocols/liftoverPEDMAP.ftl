#MOLGENIS nodes=1 cores=1 mem=2

#FOREACH study,chr


#Parameter mapping
chr="${chr}"
studyInputDir="${studyInputDir}"
outputFolder="${outputFolder}"
outputFolderTmp="${outputFolderTmp}"
outputFolderChrDir="${outputFolderChrDir}"
liftOverChainFile="${liftOverChainFile}"
liftOverUcscBin="${liftOverUcscBin}"
plinkBin="${plinkBin}"

${stage} liftOverUcsc/${liftOverUcscVersion}
${stage} plink/${plinkVersion}

<#noparse>

#Echo parameter values
echo "chr: ${chr}"
echo "studyInputDir: ${studyInputDir}"
echo "outputFolder: ${outputFolder}"
echo "outputFolderTmp: ${outputFolderTmp}"
echo "outputFolderChrDir: ${outputFolderChrDir}"
echo "liftOverChainFile: ${liftOverChainFile}"
echo "liftOverUcscBin: ${liftOverUcscBin}"
echo "plinkBin: ${plinkBin}"

startTime=$(date +%s)

#Check if outputs exist
alloutputsexist \
	"${outputFolderChrDir}/chr${chr}.ped" \
	"${outputFolderChrDir}/chr${chr}.map" \
	"${outputFolderChrDir}/chr${chr}.fam"

#Create output directories
mkdir -p $outputFolder
mkdir -p $outputFolderChrDir
mkdir -p $outputFolderTmp

#Retrieve input Files
inputs $studyInputDir/chr$chr.ped
inputs $studyInputDir/chr$chr.map
inputs $studyInputDir/chr$chr.fam
getFile $studyInputDir/chr$chr.ped
getFile $studyInputDir/chr$chr.map
getFile $studyInputDir/chr$chr.fam

#create bed file based on map file
awk '{$5=$2;$2=$4;$3=$4+1;$1="chr"$1;print $1,$2,$3,$5}' OFS="\t" $studyInputDir/chr$chr.map > $outputFolderTmp/chr$chr.old.bed

#map to b37
$liftOverUcscBin \
	-bedPlus=4 $outputFolderTmp/chr$chr.old.bed \
	$liftOverChainFile \
	$outputFolderTmp/chr$chr.new.bed \
	$outputFolderTmp/chr$chr.new.unmapped.txt

#create list of unmapped snps
awk '/^[^#]/ {print $4}' $outputFolderTmp/chr$chr.new.unmapped.txt > $outputFolderTmp/chr$chr.new.unmappedSnps.txt

#create mappings file used by plink
awk '{print $4, $2}' OFS="\t" $outputFolderTmp/chr$chr.new.bed > $outputFolderTmp/chr$chr.new.Mappings.txt 

#Copy original fam file to new output directory
cp $studyInputDir/chr$chr.fam $outputFolderChrDir/chr$chr.fam
putFile $outputFolderChrDir/chr$chr.fam

#create new plink data without the unmapped snps                            
$plinkBin \
	--noweb \
	--file $studyInputDir/chr$chr \
	--recode \
	--out $outputFolderChrDir/~chr$chr \
	--exclude $outputFolderTmp/chr$chr.new.unmappedSnps.txt \
	--update-map $outputFolderTmp/chr$chr.new.Mappings.txt                        

#Get return code from last program call
returnCode=$?

echo "returnCode Plink: ${returnCode}"

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in $outputFolderChrDir/~chr$chr* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
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