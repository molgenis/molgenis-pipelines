#MOLGENIS nodes=2 ppn=1 mem=25gb walltime=06:00:00

#Parameter mapping
#string seqType
#string intermediateDir
#string sampleMergedBam
#string sampleMergedDedupBam
#string annotationRefFlat
#string insertsizeMetrics
#string insertsizeMetricspdf
#string insertsizeMetricspng
#string tempDir
#string scriptDir
#string flagstatMetrics
#string recreateinsertsizepdfR
#string qcMatrics
#string rnaSeqMetrics
#string dupStatMetrics
#string starLogFile
#string externalSampleID
#string picardVersion
#string anacondaVersion
#string samtoolsVersion
#string NGSUtilsVersion
#string pythonVersion
#string picardJar


#Load module
module load ${picardVersion}
module load ${samtoolsVersion}
module load ${pythonVersion}
module load ${NGSUtilsVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	echo -e "generate insertSizeMatrics"


	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} CollectInsertSizeMetrics \
        I=${sampleMergedBam} \
        O=${insertsizeMetrics} \
        H=${insertsizeMetricspdf} \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=${tempDir}/processing

        # Overwrite the PDFs that were just created by nicer onces:
        ${recreateinsertsizepdfR} \
        --insertSizeMetrics ${insertsizeMetrics} \
        --pdf ${insertsizeMetricspdf}

	#convert pdf to png
	convert -density 150 ${insertsizeMetricspdf} -quality 90 ${insertsizeMetricspng}	

	#Duplicates statistics.
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} MarkDuplicates \
        I=${sampleMergedBam} \
        O=${sampleMergedDedupBam} \
        M=${dupStatMetrics} AS=true

	#Flagstat for reads mapping to the genome.
	samtools flagstat ${sampleMergedDedupBam} >  ${flagstatMetrics}
	perl -nle 'print $2,"|\t",$1 while m%^([0-9]+)+.+0\s(.+)%g;' ${flagstatMetrics} > ${starLogFile}

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} CollectRnaSeqMetrics \
	REF_FLAT=${annotationRefFlat} \
	I=${sampleMergedBam} \
	STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
	CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
	O=${rnaSeqMetrics}	

	#convert pdf to png
	convert -density 150 ${rnaSeqMetrics}.pdf -quality 90 ${rnaSeqMetrics}.png	

	# Collect QC data from several QC matricses, and write a tablular output file.

	#add header to qcMatrics
        echo "Sample:	${externalSampleID}" > ${qcMatrics}

	python $EBROOTNGSMINUTILS/pull_RNA_Seq_Stats.py \
	-i ${insertsizeMetrics} \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-s ${starLogFile} \
	>> ${qcMatrics}	
	
elif [ ${seqType} == "SR" ]
then

	#Duplicates statistics.
	
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} MarkDuplicates \	
        I=${sampleMergedBam} \
        O=${sampleMergedDedupBam} \
        M=${dupStatMetrics} AS=true

        #Flagstat for reads mapping to the genome.
        samtools flagstat ${sampleMergedDedupBam} \
        > ${flagstatMetrics}

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} CollectRnaSeqMetrics \        
        REF_FLAT=${annotationRefFlat} \
        I=${sampleMergedDedupBam} \
        STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
        CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
        O=${rnaSeqMetrics}
	
	#convert pdf to png
	convert -density 150 ${rnaSeqMetrics}.pdf -quality 90 ${rnaSeqMetrics}.png
	
	#add header to qcMatrics
	echo "Sample:	${externalSampleID}" > ${qcMatrics} 

	#Pull RNASeq stats without intsertSizeMatrics	
	python $EBROOTNGSMINUTILS/pull_RNA_Seq_Stats.py \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-s ${starLogFile} \
	>> ${qcMatrics}
fi
