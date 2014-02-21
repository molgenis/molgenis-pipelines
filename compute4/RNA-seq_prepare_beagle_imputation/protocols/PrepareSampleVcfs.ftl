#MOLGENIS walltime=24:00:00 nodes=1 cores=2 mem=6

#FOREACH sample

sampleFolder="${sampleFolder}"
sample="${sample}"
mergedFolder="${mergedFolder}"
prepareVcfJar="${prepareVcfJar}"
beagleWindow="${beagleWindow}"
refInfoFolder="${refInfoFolder}"
tabix="${tabix}"
bgzip="${bgzip}"
sampleTmpDir=${sampleTmpDir}

<#noparse>

echo "sample: ${sample}"
echo "sample folder: ${sampleFolder}"
echo "merge folder: ${mergedFolder}"

alloutputsexist ${sampleTmpDir}/chr22.vcf.gz ${sampleTmpDir}/chr22.vcf.gz.tbi

mkdir -p ${sampleTmpDir}

module load jdk

echo "copy to local"
cp -v ${sampleFolder}/${sample}.gatk.chr*.vcf.gz ${TMPDIR}/
mkdir ${TMPDIR}/ref/
cp -v ${refInfoFolder}/chr*.txt ${TMPDIR}/ref/
echo "copy complete"

mkdir ${TMPDIR}/res/

for chr in {1..22}
do
	
	echo "Processing chr: ${chr}"

	if java -jar ${prepareVcfJar} \
		--chunkSize ${beagleWindow} \
		--excludedMarkers ${sampleTmpDir}/notUsed.txt \
		--outputVcf ${TMPDIR}/res/chr${chr}.vcf \
		--refVariants ${refInfoFolder}/chr${chr}.txt \
		--studyVcf ${sampleFolder}/${sample}.gatk.chr${chr}.vcf.gz
	then
		
		rm ${sampleTmpDir}/notUsed.txt
		
		${bgzip} -f ${TMPDIR}/res/chr${chr}.vcf
		${tabix} -f -p vcf ${TMPDIR}/res/chr${chr}.vcf.gz
		
		rm -f ${sampleTmpDir}/chr${chr}.vcf.gz.tbi
		rm -f ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz
		rm -f ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz.tbi
		
		if cp ${TMPDIR}/res/chr${chr}.vcf.gz ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz
		then 
			mv ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz ${sampleTmpDir}/chr${chr}.vcf.gz
		else 
			echo "copy error vcf file"
			exit 1
		fi
		
		if cp ${TMPDIR}/res/chr${chr}.vcf.gz.tbi ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz.tbi
		then 
			mv ${sampleTmpDir}/___TMP___chr${chr}.vcf.gz.tbi ${sampleTmpDir}/chr${chr}.vcf.gz.tbi
		else 
			echo "copy error tabix file"
			exit 1
		fi
		
	else
		echo "error running prepare vcf jar"
		exit 1
	fi
	
	
	
done


</#noparse>
