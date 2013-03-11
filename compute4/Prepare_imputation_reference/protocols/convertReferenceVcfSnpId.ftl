#MOLGENIS walltime=06:00:00 nodes=1 cores=1 mem=1

#FOREACH referenceName,chr

inputs ${chrVcfReferenceIntermediateFile}
alloutputsexist ${chrVcfReferenceFile}

mkdir -p ${vcfReferenceFolder}

perl ${convertVcfIdsScript} -inputvcf ${chrVcfReferenceIntermediateFile} -outputvcf ${chrVcfReferenceFileTmp} -delimiter ${convertVcfIdsScriptDelimiter}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	
	echo -e "\nMoving temp files to final files\n\n"
	mv ${chrVcfReferenceFileTmp} ${chrVcfReferenceFile}
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi

#Md5sum and gzip *.vcf & *.vcf.vcfidx
cd ${vcfReferenceFolder}

echo "Starting md5sum for chr${chr}"

md5sum chr${chr}.vcf > ${chrVcfReferenceFileMd5}
md5sum chr${chr}.vcf.vcfidx > ${chrVcfReferenceFileIdxMd5}

echo "Starting gzipping for chr${chr}"
gzip -c ${chrVcfReferenceFile} > ${chrVcfReferenceFileGz}
gzip -c ${chrVcfReferenceFileIdx} > ${chrVcfReferenceFileIdxGz}

echo "Done with chr${chr}"
