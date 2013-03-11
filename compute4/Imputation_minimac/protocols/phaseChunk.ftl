#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk,sampleChunk

getFile ${machBin}

getFile ${studyMerlinChrDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.dat
getFile ${studyPedMapChrDir}/chr${chr}_sampleChunk${sampleChunk}.ped

inputs "${studyMerlinChrDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.dat"
inputs "${studyPedMapChrDir}/chr${chr}_sampleChunk${sampleChunk}.ped"

#alloutputsexist \
#	"${prePhasingResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.erate" \
#	"${prePhasingResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.gz" \
#	"${prePhasingResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.rec" \
#	"${prePhasingResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}-mach.log"


mkdir -p ${sampleChunkChrDir}
mkdir -p ${prePhasingChrResultDir}

${machBin} \
	-d ${studyMerlinChrDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.dat \
	-p ${studyPedMapChrDir}/chr${chr}_sampleChunk${sampleChunk}.ped \
	--prefix ${prePhasingChrResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk} \
	--rounds ${phasingRounds} \
	--states ${phasingStates} \
	--phase \
	2>&1 | tee -a ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}-mach.log

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	mv ${prePhasingChrResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.erate ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.erate
	mv ${prePhasingChrResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.gz ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.gz
	mv ${prePhasingChrResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.rec ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.rec

	putFile ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.erate
	putFile ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.gz
	putFile ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.rec
	putFile ${prePhasingChrResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}-mach.log	
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi

