#MOLGENIS nodes=1 cores=1 mem=2G

#FOREACH study,chr


#Parameter mapping
#string chr
#string studyInputDir
#string LiftoverOutputFolder
#string LiftoverOutputFolderTmp
#string LiftoverOutputFolderChrDir
#string liftOverChainFile
#string liftOverUcscBin
#string plinkBin
#string stage
#string liftOverUcscVersion
#string plinkVersion

if hash ${stage} 2>/dev/null; then
	${stage} liftOverUcsc/${liftOverUcscVersion}
	${stage} plink/${plinkVersion}
fi

#Make a random temporary folder
#NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#LiftoverOutputFolderTmp=${LiftoverOutputFolderTmp}_${NEW_UUID}

#Echo parameter values
echo "chr: ${chr}"
echo "studyInputDir: ${studyInputDir}"
echo "LiftoverOutputFolder: ${LiftoverOutputFolder}"
echo "LiftoverOutputFolderTmp: ${LiftoverOutputFolderTmp}"
echo "LiftoverOutputFolderChrDir: ${LiftoverOutputFolderChrDir}"
echo "liftOverChainFile: ${liftOverChainFile}"
echo "liftOverUcscBin: ${liftOverUcscBin}"
echo "plinkBin: ${plinkBin}"
echo "stage: ${stage}"

startTime=$(date +%s)

#Check if outputs exist
alloutputsexist \
	"${LiftoverOutputFolder}/chr${chr}.bed" \
	"${LiftoverOutputFolder}/chr${chr}.bim" \
	"${LiftoverOutputFolder}/chr${chr}.fam" 

#Create output directories
mkdir -p $LiftoverOutputFolder
#mkdir -p $LiftoverOutputFolderChrDir
mkdir -p $LiftoverOutputFolderTmp

#Retrieve input Files
inputs $studyInputDir/chr$chr.ped
inputs $studyInputDir/chr$chr.map
getFile $studyInputDir/chr$chr.ped
getFile $studyInputDir/chr$chr.map

#create bed file based on map file
awk '{$5=$2;$2=$4;$3=$4+1;$1="chr"$1;print $1,$2,$3,$5}' OFS="\t" $studyInputDir/chr$chr.map > $LiftoverOutputFolderTmp/chr$chr.old.bed

#map to b37
$liftOverUcscBin \
	-bedPlus=4 $LiftoverOutputFolderTmp/chr$chr.old.bed \
	$liftOverChainFile \
	$LiftoverOutputFolderTmp/chr$chr.new.bed \
	$LiftoverOutputFolderTmp/chr$chr.new.unmapped.txt

#create list of unmapped snps
awk '/^[^#]/ {print $4}' $LiftoverOutputFolderTmp/chr$chr.new.unmapped.txt > $LiftoverOutputFolderTmp/chr$chr.new.unmappedSnps.txt

#create mappings file used by plink
awk '{print $4, $2}' OFS="\t" $LiftoverOutputFolderTmp/chr$chr.new.bed > $LiftoverOutputFolderTmp/chr$chr.new.Mappings.txt 


#create new plink data without the unmapped snps                            
$plinkBin \
	--noweb \
	--file $studyInputDir/chr$chr \
	--recode \
	--out $LiftoverOutputFolderTmp/chr$chr.unordered \
	--exclude $LiftoverOutputFolderTmp/chr$chr.new.unmappedSnps.txt \
	--update-map $LiftoverOutputFolderTmp/chr$chr.new.Mappings.txt                        

#Get return code from last program call
returnCode=$?

#This simple run, reorder SNPs in case liftoering produced unorder positions
# /target/gpfs2/gcc/tools/plink-1.07-x86_64/plink --noweb --recode --file chr1 --out test

echo "returnCode Plink: ${returnCode}"

if [ $returnCode -eq 0 ]
then
	$plinkBin \
		--noweb \
		--file $LiftoverOutputFolderTmp/chr$chr.unordered  \
		--recode \
		--make-bed \
		--out $LiftoverOutputFolderTmp/~chr$chr

	#Get return code from last program call
	returnCode=$?
	echo "returnCode Plink: ${returnCode}"
fi

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	for tempFile in $LiftoverOutputFolderTmp/~chr$chr* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		finalFile=${LiftoverOutputFolder}/$(basename $finalFile)
		echo "Copying temp file: ${tempFile} to ${finalFile}"
		cp $tempFile $finalFile
		putFile $finalFile
	done

	echo -e "\nMoving resulting files to the final destination\n"
	cp $LiftoverOutputFolderTmp/chr$chr.{bed,bim,fam} $LiftoverOutputFolder/

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1

fi

endTime=$(date +%s)


#Source: http://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds-in-bash


num=$(($endTime-$startTime))
min=0
hour=0
day=0
if ((num>59));then
    sec=$(($num%60))
    num=$(($num/60))
    if ((num>59));then
        min=$(($num%60))
        num=$(($num/60))
        if ((num>23));then
            hour=$(($num%24))
            day=$(($num/24))
        else
            hour=${num}
        fi
    else
        min=${num}
    fi
else
    sec=${num}
fi
echo "Running time: ${day} days ${hour} hours ${min} mins ${sec} secs"




