#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=2

#FOREACH sample


phasedFolder="${phasedFolder}"
imputationFolder="${imputationFolder}"
JAVA_HOME="${JAVA_HOME}"
tooldir="${tooldir}"
chunkFile="${chunkFile}"
impute2Bin="${impute2Bin}"

sample="${sample}"
snvmixOut="${snvmixOut}"

<#noparse>



echo "phasedFolder=${phasedFolder}"
echo "sample=${sample}"

additonalImpute2Param="-Ne 20000 -k_hap 1500"

imputationIntermediatesFolder="${imputationFolder}/imputationChunks/"


mkdir -p $imputationIntermediatesFolder

IFS=$'\r\n'

chunkFileLines=($(cat ${chunkFile}))

unset IFS

#remove header
unset chunkFileLines[0]

#loop over the chunkFileLines
for chunkLine in "${chunkFileLines[@]}"
do


	chunkElements=(${chunkLine})
	
	chr=${chunkElements[0]}
	fromChrPos=${chunkElements[1]}
	toChrPos=${chunkElements[2]}
	
	echo "chr: ${chr}"
	echo "fromChrPos: ${fromChrPos}"
	echo "toChrPos: ${toChrPos}"

	tmpOutput="${imputationIntermediatesFolder}/~chr${chr}_${fromChrPos}-${toChrPos}"
	finalOutput="${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}"
	
	#Skip if chunk is imputed
	if [ -f "${finalOutput}" ] && [ -f "${finalOutput}_info" ]
	then
		echo "skipping chunk"
		continue
	fi
	
	known_haps_g="${phasedFolder}/${sample}chr${chr}.haps"
	m="/target/gpfs2/gcc/resources/geneticMap/hapmapPhase2/b37/genetic_map_chr${chr}_combined_b37.txt"
	h="/target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.hap.gz"
	l="/target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.legend.gz"

	#
	#
	##
	### Start old imputation script
	##
	#
	#
	
	inputs $known_haps_g
	inputs $m
	inputs $h
	inputs $l

	$impute2Bin \
		-known_haps_g $known_haps_g \
		-m $m \
		-h $h \
		-l $l \
		-int $fromChrPos $toChrPos \
		-o $tmpOutput \
		-use_prephased_g \
		$additonalImpute2Param
			
	#Get return code from last program call
	returnCode=$?
	
	echo "returnCode impute2: ${returnCode}"
	
	if [ $returnCode -eq 0 ]
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
		
			
		
		echo -e "\nMoving temp files to final files\n\n"
	
		for tempFile in ${tmpOutput}* ; do
			finalFile=`echo $tempFile | sed -e "s/~//g"`
			echo "Moving temp file: ${tempFile} to ${finalFile}"
			mv $tempFile $finalFile
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
		
		echo -e "\nMoving temp files to final files\n\n"
	
		for tempFile in ${tmpOutput}* ; do
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

	#
	#
	##
	### End old imputation script
	##
	#
	#
	

done


#
#
##
### Start Concat
##
#
#

# Delete old chunk files
for chr in {1..22}
do
	rm -f ${imputationFolder}/~chr${chr}
	rm -f ${imputationFolder}/~chr${chr}_info
	rm -f ${imputationFolder}/chr${chr}
	rm -f ${imputationFolder}/chr${chr}_info
done

# Header set is false
for chr in {1..22}
do
	headerSet[${chr}]="false"
done

#loop over the chunkFileLines
for chunkLine in "${chunkFileLines[@]}"
do

	chunkElements=(${chunkLine})
	
	chr=${chunkElements[0]}
	fromChrPos=${chunkElements[1]}
	toChrPos=${chunkElements[2]}
	
	echo "chr: ${chr}"
	echo "fromChrPos: ${fromChrPos}"
	echo "toChrPos: ${toChrPos}"
	
	cat ${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos} >> ${imputationFolder}/~chr${chr}
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append gen${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos} to ${imputationFolder}/~chr${chr}" >&2
		exit -1
	fi
	
	chunkInfoFile="${imputationIntermediatesFolder}/chr${chr}_${fromChrPos}-${toChrPos}_info"
	
	#Skip empty files
	lineCount=`wc -l ${chunkInfoFile} | awk '{print $1}'`
	echo "linecount ${lineCount} in: ${chunkInfoFile}"
	if [ "$lineCount" -eq "0" ]
	then
		echo "skipping empty info file: ${chunkInfoFile}" 
		continue
	fi

	#Print header if not yet done needed 
	if [ "${headerSet[$chr]}" == "false" ]
	then
		echo "print header from: ${chunkInfoFile}"
		head -n 1 < $chunkInfoFile >> ${imputationFolder}/~chr${chr}_info
		
		returnCode=$?
		if [ $returnCode -ne 0 ]
		then
			echo "Failed to print header of info file ${chunkInfoFile} to ${imputationFolder}/~chr${chr}_info" >&2
			exit -1
		fi
		
		headerSet[${chr}]="true"
	fi
	
	#Cat without header
	tail -n +2 < $chunkInfoFile >> ${imputationFolder}/~chr${chr}_info
	
	returnCode=$?
	if [ $returnCode -ne 0 ]
	then
		echo "Failed to append info file ${chunkInfoFile} to ${imputationFolder}/~chr${chr}_info" >&2
		exit -1
	fi
	

done

for chr in {1..22}
do
	mv ${imputationFolder}/~chr${chr} ${imputationFolder}/chr${chr}
	mv ${imputationFolder}/~chr${chr}_info ${imputationFolder}/chr${chr}_info
done

#
#
##
### End Concat
##
#
#



</#noparse>
