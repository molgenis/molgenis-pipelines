#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=1

#FOREACH referenceName

inputs ${ssvQuoted(chrVcfReferenceFile)}
alloutputsexist ${ssvQuoted(chrTriTyperGenotypeMatrix)}
alloutputsexist ${ssvQuoted(chrTriTyperIndividuals)}
alloutputsexist ${ssvQuoted(chrTriTyperPhenotypeInformation)}
alloutputsexist ${ssvQuoted(chrTriTyperSNPMappings)}
alloutputsexist ${ssvQuoted(chrTriTyperSNPs)}

mkdir -p ${triTyperFolderTemp}


java -jar ${ConvertVcfToTriTyperJar} \
${vcfReferenceFolder} \
${triTyperFolderTemp}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"
	mv ${triTyperFolderTemp} ${triTyperFolder}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi