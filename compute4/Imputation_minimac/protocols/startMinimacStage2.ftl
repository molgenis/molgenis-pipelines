#MOLGENIS walltime=05:00:00 nodes=1 cores=1 mem=4

#FOREACH autostart

getFile ${concatWorksheetsJar}
getFile ${ssvQuoted(finalChunkChrWorksheet)}
getFile ${ssvQuoted(chunkChrWorkSheetResult)}

<#list finalChunkChrWorksheet as chunkFile>
	getFile ${chunkFile}
</#list>


inputs "${ssvQuoted(finalChunkChrWorksheet)}"
alloutputsexist \
	"${projectPhasingJobsDir}/check_for_submission.txt" \
	"${concattedChunkWorksheet}" \
	"${projectPhasingJobsDirTarGz}"


${stage} jdk/${javaversion}

mkdir -p ${McScripts}

java -jar ${concatWorksheetsJar} \
	${tmpConcattedChunkWorksheet} \
	${ssvQuoted(finalChunkChrWorksheet)}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	mv ${tmpConcattedChunkWorksheet} ${concattedChunkWorksheet}

	putFile ${concattedChunkWorksheet}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi


java -jar ${concatWorksheetsJar} \
	${tmpConcattedChunkChrWorkSheetResult} \
	${ssvQuoted(chunkChrWorkSheetResult)}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"

	mv ${tmpConcattedChunkChrWorkSheetResult} ${ConcattedChunkChrWorkSheetResult}

	putFile ${ConcattedChunkChrWorkSheetResult}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi




#Call compute to generate phasing jobs

mkdir -p ${projectPhasingJobsDir}

# Execute MOLGENIS/compute to create job scripts.
sh ${McDir}/molgenis_compute.sh \
	-inputdir=. \
	-worksheet="${concattedChunkWorksheet}" \
	-parameters="${McParameters}" \
	-workflow="${McProtocols}/../workflowMinimacStage2.csv" \
	-protocols="${McProtocols}/" \
	-outputdir="${projectPhasingJobsDir}/" \
	-id="${McId}"


#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then
	
	echo -e "\nJob generation succesful!\n\n"
	
	perl -pi -e "s/sleep 8/sleep 0/" ${projectPhasingJobsDir}/submit.sh

	<#if autostart == "TRUE">
		cd ${projectPhasingJobsDir}
		sh submit.sh
		touch ${projectPhasingJobsDir}/check_for_submission.txt
	<#elseif autostart == "FALSE">

		echo "No autostart selected"
		
		echo "You can submit your jobs using the following command:"
		echo "cd ${projectPhasingJobsDir}"
		echo "sh submit.sh"
		
		
	</#if>

	tar czf ${projectPhasingJobsDirTarGz} ${projectPhasingJobsDir}
	putFile ${projectPhasingJobsDirTarGz}
	
else
	
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi



