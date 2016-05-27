#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=06:00:00

#Parameter mapping
#string seqType
#string intermediateDir
#string sampleMergedBam
#string sampleMergedDedupBam
#string annotationRefFlat
#string annotationIntervalList
#string indexSpecies
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
#string alignmentMetrics
#string externalSampleID
#string picardVersion
#string anacondaVersion
#string samtoolsVersion
#string NGSRNAVersion
#string pythonVersion
#string ghostscriptVersion
#string picardJar
#string project
#string collectMultipleMetricsPrefix
#string groupname
#string tmpName

#Load module
module load ${picardVersion}
module load ${samtoolsVersion}
module load ${pythonVersion}
module load ${NGSRNAVersion}
module load ${ghostscriptVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	echo -e "generate CollectMultipleMetrics"

	# Picard CollectMultipleMetrics
        java -jar -Xmx6g -XX:ParallelGCThreads=4 ${EBROOTPICARD}/${picardJar} CollectMultipleMetrics \
	I=${sampleMergedDedupBam} \
        O=${collectMultipleMetricsPrefix} \
        R=${indexSpecies} \
        PROGRAM=CollectAlignmentSummaryMetrics \
        PROGRAM=QualityScoreDistribution \
        PROGRAM=MeanQualityByCycle \
        PROGRAM=CollectInsertSizeMetrics \
        TMP_DIR=${tempDir}/processing
	

	#convert pdf to png
	convert -density 150 ${insertsizeMetricspdf} -quality 90 ${insertsizeMetricspng}

	#Flagstat for reads mapping to the genome.
	samtools flagstat ${sampleMergedDedupBam} >  ${flagstatMetrics}

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} CollectRnaSeqMetrics \
	REF_FLAT=${annotationRefFlat} \
	I=${sampleMergedDedupBam} \
	STRAND_SPECIFICITY=NONE \
	CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
	RIBOSOMAL_INTERVALS=${annotationIntervalList} \
	VALIDATION_STRINGENCY=LENIENT \
	O=${rnaSeqMetrics}

	#convert pdf to png
	convert -density 150 ${rnaSeqMetrics}.pdf -quality 90 ${rnaSeqMetrics}.png

	# Collect QC data from several QC matricses, and write a tablular output file.

	#add header to qcMatrics
        echo "Sample:	${externalSampleID}" > ${qcMatrics}

	python ${EBROOTNGS_RNA}/report/pull_RNA_Seq_Stats.py \
	-i ${insertsizeMetrics} \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-a ${alignmentMetrics} \
	>> ${qcMatrics}

elif [ ${seqType} == "SR" ]
then

        #Flagstat for reads mapping to the genome.
        samtools flagstat ${sampleMergedDedupBam} > ${flagstatMetrics}


	echo -e "generate CollectMultipleMetrics"

        # Picard CollectMultipleMetrics
        java -jar -Xmx6g -XX:ParallelGCThreads=4 ${EBROOTPICARD}/${picardJar} CollectMultipleMetrics \
        I=${sampleMergedDedupBam} \
        O=${collectMultipleMetricsPrefix} \
        R=${indexSpecies} \
        PROGRAM=CollectAlignmentSummaryMetrics \
        PROGRAM=QualityScoreDistribution \
        PROGRAM=MeanQualityByCycle \
        PROGRAM=CollectInsertSizeMetrics \
        TMP_DIR=${tempDir}/processing


	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} CollectRnaSeqMetrics \
        REF_FLAT=${annotationRefFlat} \
        I=${sampleMergedDedupBam} \
	STRAND_SPECIFICITY=NONE \
	RIBOSOMAL_INTERVALS=${annotationIntervalList} \
        CHART_OUTPUT=${rnaSeqMetrics}.pdf \
	VALIDATION_STRINGENCY=LENIENT \
        O=${rnaSeqMetrics}

	#convert pdf to png
	convert -density 150 ${rnaSeqMetrics}.pdf -quality 90 ${rnaSeqMetrics}.png

	#add header to qcMatrics
	echo "Sample:	${externalSampleID}" > ${qcMatrics} 

	#Pull RNASeq stats without intsertSizeMatrics
	python ${EBROOTNGS_RNA}/report/pull_RNA_Seq_Stats.py \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-a ${alignmentMetrics} \
	>> ${qcMatrics}
fi
