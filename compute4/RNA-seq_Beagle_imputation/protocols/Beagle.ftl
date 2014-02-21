#MOLGENIS walltime=100:00:00 nodes=1 cores=16 mem=60


#FOREACH sample

mergedVcfFile=${mergedVcfFile}
GoNL=${GoNL}
BeagleJar=${BeagleJar}
JAVA_HOME=${JAVA_HOME}
prepareForBeagleJar=${prepareForBeagleJar}
chr=${chr}

<#noparse>

localOutput=${TMPDIR}/
localImputedPrefix=${localOutput}chr${chr}.imputed
finalImputedPrefix=${mergedVcfFile%vcf.gz}imputed
exclMarkersFile=${localOutput}chr${chr}ExcludeRefMarkers.txt

echo "mergedVcfFile=${mergedVcfFile}"
echo "localImputedPrefix=${localImputedPrefix}"
echo "finalImputedPrefix=${finalImputedPrefix}"
echo "exclMarkersFile=${exclMarkersFile}"

if [ -s ${finalImputedPrefix}.vcf.gz ]; then
	echo "File exists: ${finalImputedPrefix}.vcf.gz"
	echo "skipping chr${chr}"
else
	echo "Processing chr${chr}"
	
	localMergedVcfFile=${localOutput}/chr${chr}.vcf.gz
	cp ${mergedVcfFile} ${localMergedVcfFile}
	
	echo "Copied the VCF file to ${localMergedVcfFile}"
	
	echo "Preparing VCFs for Beagle"
	#
	# Detect regions without SNPs in the data to be imputed
	#
	
	${JAVA_HOME}/bin/java \
	-Xmx60g \
	-Xms60g \
	-jar ${prepareForBeagleJar} \
		--chunkSize 24000 \
		--excludedMarkers ${excludeMarkers} \
		--refVariants ${GoNL}/chr${chr}.txt \
		--studyVcf ${localMergedVcfFile} \
		--outputVcf $localOutput/tmp.vcf
	rm ${localOutput}/tmp.vcf
	
	prepareReturnCode=$?
	echo "prepareReturnCode return code: $prepareReturnCode"
	
	if [ ! $prepareReturnCode -eq 0 ]; then
		echo "Prepare for Beagle failed, not making files final"
		exit 1
	fi

	#
	# Impute
	#
	
	echo "Imputation"
	
	${JAVA_HOME}/bin/java \
	-Djava.io.tmpdir=$TMPDIR \
	-Xmx60g \
	-Xms60g \
	-jar ${BeagleJar} \
	nthreads=10 \
	gl=${localMergedVcfFile} \
	ref=${GoNL}chr${chr}.vcf.gz \
	chrom=${chr} \
	excludemarkers=${excludeMarkers} \
	out=${localImputedPrefix}
	
	returnCode=$?
	echo "Beagle return code: $returnCode"
	if [ $returnCode -eq 0 ]; then
		echo "Moving temp files: ${localImputedPrefix}* to ${finalImputedPrefix}*"
		mv ${localImputedPrefix}.vcf.gz ${finalImputedPrefix}.vcf.gz
		mv ${localImputedPrefix}.log ${finalImputedPrefix}.log
	else
		echo "Beagle failed, not making files final"
		exit 1
	fi
fi

</#noparse>