#MOLGENIS nodes=1 cores=1 mem=4G

#Parameter mapping
#string knownHapsG
#string m
#string h
#string l
#string additonalImpute2Param
#string chr
#string fromChrPos
#string toChrPos
#string fromSample
#string toSample
#string ImputeOutputFolder
#string imputationIntermediatesFolder
#string ImputeOutputFolderTemp
#string impute2Bin
#string stage
#string impute2version

#output impute2ChunkOutput
#output impute2ChunkOutputInfo

if ${stage} impute/${impute2version};
then
	echo "Success: impute/${impute2version};"
else
	echo "Failed: ${stage} impute/${impute2version}"
fi

tmpOutput="${ImputeOutputFolderTemp}/~chr${chr}_${fromChrPos}-${toChrPos}_${fromSample}-${toSample}"
finalOutput="${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_${fromSample}-${toSample}"

echo "knownHapsG: ${knownHapsG}"
echo "chr: ${chr}"
echo "fromChrPos: ${fromChrPos}"
echo "toChrPos: ${toChrPos}"
echo "fromSample: ${fromSample}"
echo "toSample: ${toSample}"
echo "interMediFolder: ${imputationIntermediatesFolder}"
echo "tmpOutput: ${tmpOutput}"
echo "ImputeOutputFolder: ${ImputeOutputFolder}"
echo "ImputeOutputFolderTemp: ${ImputeOutputFolderTemp}"
echo "finalOutput: ${finalOutput}"

impute2ChunkOutput=${finalOutput}
impute2ChunkOutputInfo=${finalOutput}_info

alloutputsexist \
	"${finalOutput}" \
	"${finalOutput}_info" \
	"${finalOutput}_info_by_sample" \
	"${finalOutput}_summary" \
	"${finalOutput}_warnings"

startTime=$(date +%s)

genotype_aligner_output_haps=$ImputeOutputFolder/chr${chr}.haps
genotype_aligner_output_sample=$ImputeOutputFolder/chr${chr}.sample
echo "genotype_aligner_output_haps: ${genotype_aligner_output_haps}"
echo "genotype_aligner_output_sample: ${genotype_aligner_output_sample}"

echo "tmpOutput: ${tmpOutput}"

getFile ${knownHapsG}
inputs ${knownHapsG}

getFile ${m}
inputs ${m}

# $h can be multiple files. Here we will check each file and do a getFile, if needed, for each file
for refH in ${h}
do
	echo "Reference haplotype file: ${refH}"
	getFile ${refH}
	inputs ${refH}
done

# $l can be multiple files. Here we will check each file and do a getFile, if needed, for each file
for refL in ${l}
do
	echo "Reference legend file: ${refL}"
	getFile ${refL}
	inputs ${refL}
done

# DECLARE POSSIBLE VALUES FOR additonalImpute2Param HERE
impute2FileArg[0]="-sample_g_ref"
impute2FileArg[1]="-exclude_samples_g"
impute2FileArg[2]="-exclude_snps_g"
impute2FileArg[3]="-sample_g"

# This function test if element is in array
# http://stackoverflow.com/questions/3685970/bash-check-if-an-array-contains-a-value
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 1; done
  return 0
}


additonalImpute2ParamArray=($additonalImpute2Param)

# Loop over all additional args. If arg is encounterd that requeres file then do inputs and getFile on next element
for (( i=0; i<${#additonalImpute2ParamArray[@]}; i++ ));
do
	currentArg=${additonalImpute2ParamArray[$i]}
	containsElement $currentArg ${impute2FileArg[@]}
	if [[ $? -eq 1 ]]; 
	then 
		
		i=`expr $i + 1`
		
		file=${additonalImpute2ParamArray[$i]}
		
		echo "File for this argument: ${currentArg} will get and is requered for this script to start ${file}"
		inputs ${file}
		get ${file}
		echo "Found additional Impute2 file: ${file}"
		
	fi
	
done


mkdir -p ${imputationIntermediatesFolder}
mkdir -p ${ImputeOutputFolderTemp}

#START OF SAMPLE SPLITTING 

#Create subset of samples to exclude 
sample_subset_to_exclude=${tmpOutput}.toExclude
echo "Samples excluded from this run: ${sample_subset_to_exclude}"

# Process substitution is not supported from all shells : http://www.gnu.org/software/bash/manual/bashref.html#Process-Substitution so it's better to avoid it.
# This is the way to implement the following three lines in a single command with process substitution:
# cat <(cat ${genotype_aligner_output_sample} | tail -n +3 | head -n `expr ${fromSample} - 1`) <(cat ${genotype_aligner_output_sample} | tail -n +3 | tail -n +`expr ${toSample} + 1`) | cut -f 2 -d ' ' > ${sample_subset_to_exclude}

cat ${genotype_aligner_output_sample} | tail -n +3 | head -n `expr ${fromSample} - 1` > ${sample_subset_to_exclude}.part1
cat ${genotype_aligner_output_sample} | tail -n +3 | tail -n +`expr ${toSample} + 1` > ${sample_subset_to_exclude}.part2
cat ${sample_subset_to_exclude}.part1 ${sample_subset_to_exclude}.part2 | cut -f 2 -d ' ' > ${sample_subset_to_exclude}

#END OF SAMPLE SPLITTING

#From http://mathgen.stats.ox.ac.uk/impute/impute_v2.html
#To use pre-phased study data in this example, you would replace the -g file with a -known_haps_g file and add the -use_prephased_g flag to your IMPUTE2 command.

#	-known_haps_g ${knownHapsG} 
if ${impute2Bin} \
	-known_haps_g ${genotype_aligner_output_haps} \
	-m ${m} \
	-h ${h} \
	-l ${l} \
	-int ${fromChrPos} ${toChrPos} \
	-o ${tmpOutput} \
	-use_prephased_g \
	-sample_g ${genotype_aligner_output_sample} \
	-exclude_samples_g ${sample_subset_to_exclude} \
	${additonalImpute2Param}
then

	#If there are no SNPs in this bin we will create empty files 
	if [ ! -f ${tmpOutput}_info ]
	then
	
		echo "Impute2 did not output files. Usually this means there where no SNPs in this region so, generate empty files"
		echo "Touching file: ${tmpOutput}"
		echo "Touching file: ${tmpOutput}_info"
		echo "Touching file: ${tmpOutput}_info_by_sample"
	
		touch ${tmpOutput}
		touch ${tmpOutput}_info
		touch ${tmpOutput}_info_by_sample
	
	fi
	
		
	
	echo -e "\nCopying temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo ${tempFile} | sed -e "s/~//g"`
		finalFile=${imputationIntermediatesFolder}/$(basename $finalFile)
		echo "Copying temp file: ${tempFile} to ${finalFile}"
		cp $tempFile $finalFile
		putFile $finalFile
	done
	
elif [ `grep "ERROR: There are no type 2 SNPs after applying the command-line settings for this run"  ${tmpOutput}_summary | wc -l | awk '{print $1}'` == 1 ]
then

	if [ ! -f ${tmpOutput}_info ]
	then
		echo "Impute2 found no type 2 SNPs in this region. We now create empty output"
		echo "Touching file: ${tmpOutput}"
		echo "Touching file: ${tmpOutput}_info"
		echo "Touching file: ${tmpOutput}_info_by_sample"
	
		touch ${tmpOutput}
		touch ${tmpOutput}_info
		touch ${tmpOutput}_info_by_sample
		
	fi
	
	echo -e "\nCopying temp files to final files\n\n"

	for tempFile in ${tmpOutput}* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		finalFile=${imputationIntermediatesFolder}/$(basename $finalFile)
		echo "Copyinh temp file: ${tempFile} to ${finalFile}"
		cp ${tempFile} ${finalFile}
		putFile ${finalFile}
	done
		

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

