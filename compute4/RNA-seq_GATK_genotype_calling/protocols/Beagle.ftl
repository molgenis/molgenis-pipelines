#MOLGENIS walltime=100:00:00 nodes=1 cores=1 mem=6


#FOREACH sample

gatkVCF=${gatkVCF}
GoNL=${GoNL}
BeagleJar=${BeagleJar}
tabixDir=${tabixDir}
JAVA_HOME=${JAVA_HOME}
prepareForBeagleJar=${prepareForBeagleJar}
sampleOutput=${sampleOutput}
sample=${sample}

<#noparse>

localSampleOutput=${TMPDIR}/
imputedDir=${sampleOutput}/beagleImputed/

readyVCFDir=${localSampleOutput}/vcfImputationReady/
exclMarkersDir=${localSampleOutput}/beagleExcludeRefMarkers/

mkdir ${exclMarkersDir}
mkdir ${readyVCFDir}
mkdir ${imputedDir}

for chr in {1..22}
do
	imputedVCFprefix=${imputedDir}/${sample}.chr${chr}.imputed
	if [ -s ${imputedVCFprefix}.vcf.gz ]; then
		echo "File exists: ${imputedVCFprefix}.vcf.gz"
		echo "skipping chr${chr}"
	else
		echo "Processing chr${chr}"
		
		gatkVCFchr=${gatkVCF%vcf}chr${chr}.vcf.gz
		localGatkVCFchr=${localSampleOutput}/${sample}.gatk.chr${chr}.vcf.gz
		cp ${gatkVCFchr} ${localGatkVCFchr}
		
		excludeMarkers=${exclMarkersDir}/chr${chr}ExcludeRefMarkers.txt
		vcfReadyForBeagle=${readyVCFDir}/chr${chr}.vcf
		
		imputedVCFprefix=${imputedDir}/${sample}.chr${chr}.imputed
		localImputedPrefix=${localSampleOutput}/${sample}.chr${chr}.imputed
		
		echo "localGatkVCFchr=${localGatkVCFchr}"
		echo "gatkVCFchr=$gatkVCFchr"
		echo "excludeMarkers=${excludeMarkers}"
		echo "vcfReadyForBeagle=${vcfReadyForBeagle}"
		
		echo "Preparing VCFs for Beagle"
		#
		# Leave only SNPs that are present in the reference, align alleles
		#
		
		${JAVA_HOME}/bin/java \
		-Xmx6g \
		-Xms6g \
		-jar ${prepareForBeagleJar} \
			--chunkSize 24000 \
			--excludedMarkers ${excludeMarkers} \
			--outputVcf ${vcfReadyForBeagle}__tmp__ \
			--refVariants ${GoNL}/chr${chr}.txt \
			--studyVcf ${localGatkVCFchr}
		
		prepareReturnCode=$?
		echo "prepareReturnCode return code: $prepareReturnCode"
		
		if [ $prepareReturnCode -eq 0 ]; then
			echo "bgzipping ${vcfReadyForBeagle}__tmp__"
		
			${tabixDir}bgzip -f ${vcfReadyForBeagle}__tmp__
			zipReturnCode=$?
			echo "Bgzip return code: $zipReturnCode"
			if [ $zipReturnCode -eq 0 ]; then
				echo "Moving temp file: ${vcfReadyForBeagle}__tmp__.gz to ${vcfReadyForBeagle}.gz"
				mv ${vcfReadyForBeagle}__tmp__.gz ${vcfReadyForBeagle}.gz
			else
				echo "Bgzip failed"
				exit 1
			fi
		else
			echo "Prepare for Beagle failed, not making files final"
			exit 1
		fi
	
		#
		# Impute
		#
		
		echo "imputedVCFprefix=${imputedVCFprefix}"
		echo "localImputedPrefix=${localImputedPrefix}"
		
		${JAVA_HOME}/bin/java \
		-Djava.io.tmpdir=$TMPDIR \
		-Xmx6g \
		-Xms6g \
		-jar ${BeagleJar} \
		gl=${vcfReadyForBeagle}.gz \
		ref=${GoNL}chr${chr}.vcf.gz \
		chrom=${chr} \
		excludemarkers=${excludeMarkers} \
		out=${localImputedPrefix}
		
		returnCode=$?
		echo "Beagle return code: $returnCode"
		if [ $returnCode -eq 0 ]; then
			echo "Moving temp files: ${localImputedPrefix}* to ${imputedVCFprefix}*"
			mv ${localImputedPrefix}.vcf.gz ${imputedVCFprefix}.vcf.gz
			mv ${localImputedPrefix}.log ${imputedVCFprefix}.log
		else
			echo "Beagle failed, not making files final"
			exit 1
		fi
	fi
done
</#noparse>