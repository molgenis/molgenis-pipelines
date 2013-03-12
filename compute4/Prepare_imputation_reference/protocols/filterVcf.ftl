#MOLGENIS walltime=06:00:00 nodes=1 cores=1 mem=1



inputs ${chrVcfInputFile}
alloutputsexist ${chrVcfReferenceIntermediateFile}

mkdir -p ${tmpFolder}




<#assign lengthVcfPath = chrVcfInputFile?length>
<#assign isGz = chrVcfInputFile?substring(lengthVcfPath - 2, lengthVcfPath) == "gz">


${vcftoolsBin} <#if isGz> --gzvcf <#else> --vcf </#if> ${chrVcfInputFile} --out ${tmpFolder}/~chr${chr} <#if samplesToIncludeFile != ""> --keep ${samplesToIncludeFile} </#if> ${vcfFilterOptions}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"
	mv ${chrVcfReferenceIntermediateFileTemp} ${chrVcfReferenceIntermediateFile}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi