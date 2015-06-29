#MOLGENIS nodes=2 ppn=1 mem=25gb walltime=06:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeTrimmedFqGz
#string peEnd2BarcodeTrimmedFqGz
#string peEnd1BarcodeTrimmedFq
#string srBarcodeFastQcZip
#string srBarcodeTrimmedFqGz
#string srBarcodeTrimmedFq
#string intermediateDir
#string BarcodeFastQcFolder
#string BarcodeFastQcFolderPE
#string sortedBam
#string annotationRefFlat
#string insertsizeMetrics
#string insertsizeMetricspdf
#string tempDir
#string scriptDir
#string flagstatMetrics
#string recreateinsertsizepdfR
#string qcMatrics
#string rnaSeqMetrics
#string dupStatMetrics
#string starLogFile
#string externalSampleID
#string pythonVersion
#string picardVersion
#string anacondaVersion
#string samtoolsVersion


#Load module
module load picard-tools/${picardVersion}
module load Python/${pythonVersion}
module load anaconda/${anacondaVersion}
module load samtools/${samtoolsVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	echo -e "generate insertSizeMatrics"

	java -jar -Xmx10g ${PICARD_HOME}/CollectInsertSizeMetrics.jar \
        I=${sortedBam} \
        O=${insertsizeMetrics} \
        H=${insertsizeMetricspdf} \
        VALIDATION_STRINGENCY=LENIENT \
        TMP_DIR=${tempDir}/processing

        # Overwrite the PDFs that were just created by nicer onces:
        ${recreateinsertsizepdfR} \
        --insertSizeMetrics ${insertsizeMetrics} \
        --pdf ${insertsizeMetricspdf}

	#convert pdf to png
        pdftoppm -png ${insertsizeMetricspdf} > ${insertsizeMetrics}.png
	
	#unzip srBarcodeFqGz
	zcat ${peEnd1BarcodeTrimmedFqGz} > ${peEnd1BarcodeTrimmedFq} 
		
	#Generate a GCpercentage plot  
	python ${scriptDir}/gentrap_graph_seqgc.py \
	${peEnd1BarcodeTrimmedFq} \
	${intermediateDir}/${externalSampleID}.GC.png
	
	#clean up 
	rm ${peEnd1BarcodeTrimmedFq}	

	#Duplicates statistics.
        java -jar -Xmx10g ${PICARD_HOME}/MarkDuplicates.jar \
        I=${sortedBam} \
        O=${sortedBam}.mdup.bam \
        M=${dupStatMetrics} AS=true

	#Flagstat for reads mapping to the genome.
	samtools flagstat ${sortedBam}.mdup.bam >  ${flagstatMetrics}


	#CollectRnaSeqMetrics.jar
	java -jar -Xmx10g ${PICARD_HOME}/CollectRnaSeqMetrics.jar \
	REF_FLAT=${annotationRefFlat} \
	I=${sortedBam} \
	STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
	CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
	O=${rnaSeqMetrics}	

	#convert pdf to png
        pdftoppm -png ${rnaSeqMetrics}.pdf > ${rnaSeqMetrics}.png

	# Collect QC data from several QC matricses, and write a tablular output file.

	#add header to qcMatrics
        echo "Sample:	${externalSampleID}" > ${qcMatrics}

	python ${scriptDir}/pull_RNA_Seq_Stats.py \
	-1 ${BarcodeFastQcFolderPE}/fastqc_data.txt \
	-i ${insertsizeMetrics} \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-s ${starLogFile} \
	>> ${qcMatrics}	
	
elif [ ${seqType} == "SR" ]
then

	#unzip srBarcodeFqGz
        zcat ${srBarcodeTrimmedFqGz} > ${srBarcodeTrimmedFq}

        #Generate a GCpercentage plot
        python ${scriptDir}/gentrap_graph_seqgc.py \
        ${srBarcodeTrimmedFq} \
        ${intermediateDir}/${externalSampleID}.GC.png

        #clean up
        rm ${srBarcodeTrimmedFq}

	#Duplicates statistics.
        java -jar -Xmx10g ${PICARD_HOME}/MarkDuplicates.jar \
        I=${sortedBam} \
        O=${sortedBam}.mdup.bam \
        M=${dupStatMetrics} AS=true

        #Flagstat for reads mapping to the genome.
        samtools flagstat ${sortedBam}.mdup.bam \
        > ${flagstatMetrics}

	#CollectRnaSeqMetrics.jar
        java -jar -Xmx10g ${PICARD_HOME}/CollectRnaSeqMetrics.jar \
        REF_FLAT=${annotationRefFlat} \
        I=${sortedBam} \
        STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
        CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
        O=${rnaSeqMetrics}
	
	#convert pdf to png
	pdftoppm -png ${rnaSeqMetrics}.pdf > ${rnaSeqMetrics}.png
	
	#add header to qcMatrics
	echo "Sample:	${externalSampleID}" > ${qcMatrics} 

	#Pull RNASeq stats without intsertSizeMatrics	
	python ${scriptDir}/pull_RNA_Seq_Stats.py \
	-1 ${BarcodeFastQcFolder}/fastqc_data.txt \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-s ${starLogFile} \
	>> ${qcMatrics}
fi
