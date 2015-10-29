#MOLGENIS nodes=2 ppn=1 mem=25gb walltime=06:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string peEnd1BarcodeFq
#string srBarcodeFastQcZip
#string srBarcodeFqGz
#string srBarcodeFq
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
#string picardVersion
#string anacondaVersion
#string samtoolsVersion
#string NGSUtilsVersion
#string pythonVersion

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

	java -jar -Xmx4g ${EBROOTPICARD}/CollectInsertSizeMetrics.jar \
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
	convert -density 150 ${insertsizeMetricspdf} -quality 90 ${insertsizeMetricspdf}.png	

	#unzip srBarcodeFqGz
	zcat ${peEnd1BarcodeFqGz} > ${peEnd1BarcodeFq} 
		
	#Generate a GCpercentage plot  
	gentrap_graph_seqgc.py \
	${peEnd1BarcodeFq} \
	${intermediateDir}/${externalSampleID}.GC.png
	
	#clean up 
	rm ${peEnd1BarcodeFq}	

	#Duplicates statistics.
        java -jar ${EBROOTPICARD}/MarkDuplicates.jar \
        I=${sortedBam} \
        O=${sortedBam}.mdup.bam \
        M=${dupStatMetrics} AS=true

	#Flagstat for reads mapping to the genome.
	samtools flagstat ${sortedBam}.mdup.bam >  ${flagstatMetrics}

	#CollectRnaSeqMetrics.jar
	java -jar ${EBROOTPICARD}/CollectRnaSeqMetrics.jar \
	REF_FLAT=${annotationRefFlat} \
	I=${sortedBam} \
	STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
	CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
	O=${rnaSeqMetrics}	

	#convert pdf to png
        pdftoppm -png ${rnaSeqMetrics}.pdf > ${rnaSeqMetrics}.png
	convert -density 150 ${rnaSeqMetrics} -quality 90 ${rnaSeqMetrics}.png	

	# Collect QC data from several QC matricses, and write a tablular output file.

	#add header to qcMatrics
        echo "Sample:	${externalSampleID}" > ${qcMatrics}

	pull_RNA_Seq_Stats.py \
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
        zcat ${srBarcodeFqGz} > ${srBarcodeFq}

        #Generate a GCpercentage plot
        gentrap_graph_seqgc.py \
        ${srBarcodeFq} \
        ${intermediateDir}/${externalSampleID}.GC.png

        #clean up
        rm ${srBarcodeFq}

	#Duplicates statistics.
        java -jar ${EBROOTPICARD}/MarkDuplicates.jar \
        I=${sortedBam} \
        O=${sortedBam}.mdup.bam \
        M=${dupStatMetrics} AS=true

        #Flagstat for reads mapping to the genome.
        samtools flagstat ${sortedBam}.mdup.bam \
        > ${flagstatMetrics}

	#CollectRnaSeqMetrics.jar
        java -jar ${EBROOTPICARD}/CollectRnaSeqMetrics.jar \
        REF_FLAT=${annotationRefFlat} \
        I=${sortedBam} \
        STRAND_SPECIFICITY=SECOND_READ_TRANSCRIPTION_STRAND \
        CHART_OUTPUT=${rnaSeqMetrics}.pdf  \
        O=${rnaSeqMetrics}
	
	#convert pdf to png
	convert -density 150 ${rnaSeqMetrics} -quality 90 ${rnaSeqMetrics}.png
	
	#add header to qcMatrics
	echo "Sample:	${externalSampleID}" > ${qcMatrics} 

	#Pull RNASeq stats without intsertSizeMatrics	
	pull_RNA_Seq_Stats.py \
	-1 ${BarcodeFastQcFolder}/fastqc_data.txt \
	-f ${flagstatMetrics} \
	-r ${rnaSeqMetrics} \
	-d ${dupStatMetrics} \
	-s ${starLogFile} \
	>> ${qcMatrics}
fi
