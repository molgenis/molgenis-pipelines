#MOLGENIS walltime=06:00:00 nodes=1 cores=1 mem=1

inputs ${chrVcfReferenceFile}
alloutputsexist ${chrImpute2Hap}
alloutputsexist ${chrImpute2HapIndv}
alloutputsexist ${chrImpute2HapLegend}
alloutputsexist ${chrImpute2HapLog}


mkdir -p ${impute2Folder}


${vcftoolsBin} --vcf ${chrVcfReferenceFile} --out ${impute2Folder}/~${chr} --IMPUTE


#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"
	for tempFile in ${impute2Folder}/~${chr}.* ; do
		finalFile=`echo $tempFile | sed -e "s/~//g"`
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi