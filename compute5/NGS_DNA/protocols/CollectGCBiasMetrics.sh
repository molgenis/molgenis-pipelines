#MOLGENIS walltime=23:59:00 mem=6gb ppn=6


#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string picardVersion
#string gcBiasMetricsJar
#string dedupBam
#string dedupBamIdx
#string indexFile
#string collectBamMetricsPrefix
#string tempDir
#string recreateInsertSizePdfR
#string rVersion
#string capturingKit
#string seqType
#string picardJar
#string insertSizeMetrics
#string gcBiasMetrics
#string	project
#string logsDir

#Load Picard module
${stage} ${picardVersion}

#Load R module
${stage} ${rVersion}
${stage} ngs-utils
${checkStage}

makeTmpDir ${gcBiasMetrics}
tmpGcBiasMetrics=${MC_tmpFile}

#Run Picard GcBiasMetrics
java -XX:ParallelGCThreads=4 -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${gcBiasMetricsJar} \
R=${indexFile} \
I=${dedupBam} \
O=${tmpGcBiasMetrics} \
CHART=${tmpGcBiasMetrics}.pdf \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir}

    echo -e "\nGcBiasMetrics finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpGcBiasMetrics} ${gcBiasMetrics}
    mv ${tmpGcBiasMetrics}.pdf ${gcBiasMetrics}.pdf

######IS THIS STILL NEEDED, IMPROVEMENTS/UPDATES TO BE DONE?#####
#Create nicer insertsize plots if seqType is PE
#if [ "${seqType}" == "PE" ]
#then
	# Overwrite the PDFs that were just created by nicer onces:
${recreateInsertSizePdfR} \
--insertSizeMetrics ${insertSizeMetrics} \
--pdf ${insertSizeMetrics}.pdf

#else
	# Don't do insert size analysis because seqType != "PE"

#fi
