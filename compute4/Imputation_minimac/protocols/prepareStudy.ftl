#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr

getFile ${createRandomSubsetsJar}
getFile ${expandWorksheetJar}
getFile ${studyInputPedMapChr}.ped
getFile ${studyInputPedMapChr}.map
getFile ${chunkChromosomeBin}
getFile ${remoteWorksheet}

#Create study PEDMAP Chr dir
mkdir -p ${studyPedMapChrDir}

#Create directory to store Merlin data
mkdir -p ${studyMerlinChrDir}

#Load java
${stage} jdk/${javaversion}
#Load plink
${stage} plink/${plinkversion}

#Create fam file from PED file
awk '{print $1,$2,"0","0","1","2"}' ${studyInputPedMapChr}.ped > ${studyPedMapChr}.fam

echo -e '\n Testing java version\n'
java -version

echo -e '\n Available memory:\n'
free -m

echo -e '\n java -Xmx10G -version \n' 
java -Xmx10G -version

#Chunk study map file
java -jar ${createRandomSubsetsJar} \
-c ${sampleChunkSize} \
-i ${studyPedMapChr}.fam \
-o ${studyPedMapChrDir} \
-p ${project}_

returnCode=$?

if [ $returnCode -ne 0 ]
then

	echo -e "\nNon zero return code. Something went wrong creating the study chunks\n\n"
	#Return non zero return code
	exit 1

fi


#Create .csv file to be merged with original worksheet
echo "chr,sampleChunk,chrChunk" > ${chunkChrWorkSheet}

#Retrieve number of generated chunks
studyChunks=(${studyPedMapChrDir}/${project}_*chr${chr}.fam)

numStudyChunks=${r"${#studyChunks[*]}"}

###START ITERATION OVER STUDYCHUNKS###
for S in `seq 1 $numStudyChunks`
do

	#Create list of famIDs and sampleIDs to keep
	awk '{print $1,$2}' ${studyPedMapChrDir}/${project}_$S\chr${chr}.fam > ${studyPedMapChrDir}/to_keep_$S\chr${chr}.txt
	
	plink \
	--noweb \
	--recode \
	--ped ${studyInputPedMapChr}.ped \
	--map ${studyInputPedMapChr}.map \
	--out ${studyPedMapChrDir}/~chr${chr}_sampleChunk$S \
	--keep ${studyPedMapChrDir}/to_keep_$S\chr${chr}.txt
	
	#Get return code from last program call
	returnCode=$?

	if [ $returnCode -eq 0 ]
	then
	
		echo -e "\nMoving temp files to final files\n\n"

		mv ${studyPedMapChrDir}/~chr${chr}_sampleChunk$S.ped ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.ped
		mv ${studyPedMapChrDir}/~chr${chr}_sampleChunk$S.map ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.map
		mv ${studyPedMapChrDir}/~chr${chr}_sampleChunk$S.log ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.log
		putFile ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.ped
		putFile ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.map
	
	
	else
  
		echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
		#Return non zero return code
		exit 1

	fi
	

	#Convert SNP ID to chr_pos and remove 3rd column to adhere to merlin
	gawk '
		BEGIN {$1="CHROMOSOME";$2="MARKER";$3="POSITION";print $0}
		{$2=$1":"$4;print $1,$2,$4}
	' OFS="\t" ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.map > ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.map

	gawk 'BEGIN {print "T","pheno";}{print "M",$1":"$4}' ${studyPedMapChrDir}/chr${chr}_sampleChunk$S.map > ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.dat

	set +o posix

######THIS CAN BE DELETED, RIGHT?
	##Create merlin ped from genotypes outputed by imputation tool but use fam id, sample id and phenodata from original pedmap
	##paste <(awk '{print $1,$2,$3,$4,$5,$6}' ${studyPedMapChr}.ped) <(awk '{for(i=7;i<NF;i++) $(i-6) = $i;print $0}' ${preparedStudyDir}/chr${chr}.ped) -d ' ' > ${studyMerlinChrPed}
######

	putFile ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.map
	putFile ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.dat
#	putFile ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.ped
	
	
	###START ITERATION FOR CHROMOSOME CHUNKING###
	#Chunk chromosomes into pieces containing ~${chunkSize} markers

	cd ${studyMerlinChrDir}

	${chunkChromosomeBin} \
		-d ${studyMerlinChrDir}/chr${chr}_sampleChunk$S.dat \
		-n ${chunkSize} \
		-o ${chunkOverlap}

	returnCode=$?

	if [ $returnCode -ne 0 ]
	then

		echo -e "\nNon zero return code. Something went wrong creating the chromosome chunks\n\n"
		#Return non zero return code
		exit 1

	fi

	chrChunks=(${studyMerlinChrDir}/chunk*-chr${chr}_sampleChunk$S.dat.snps)

	numChrChunks=${r"${#chrChunks[*]}"}

	for c in `seq 1 $numChrChunks`
	do
		echo ${chr},$S,$c >> ${chunkChrWorkSheet}
		
		putFile ${studyMerlinChrDir}/chunk$c-chr${chr}_sampleChunk$S.dat.snps
		putFile ${studyMerlinChrDir}/chunk$c-chr${chr}_sampleChunk$S.dat
	done
	
done


#Run Jar to create full worksheet

java -jar ${expandWorksheetJar} ${remoteWorksheet} ${tmpFinalChunkChrWorksheet} ${chunkChrWorkSheet} project ${project} chr ${chr}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	mv ${tmpFinalChunkChrWorksheet} ${finalChunkChrWorksheet}
	cp ${chunkChrWorkSheet} ${chunkChrWorkSheetResult}

	putFile ${finalChunkChrWorksheet}
	putFile ${chunkChrWorkSheetResult}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi

