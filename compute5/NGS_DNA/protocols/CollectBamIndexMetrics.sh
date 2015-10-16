#MOLGENIS walltime=23:59:00 mem=6gb ppn=6


#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string bamIndexStatsJar
#string dedupBam
#string dedupBamIdx
#string collectBamMetricsPrefix
#string tempDir
#string capturingKit
#string picardJar

#Load Picard module
${stage} ${picardVersion}

makeTmpDir ${collectBamMetricsPrefix}
tmpCollectBamMetricsPrefix=${MC_tmpFile}


#Run Picard BamIndexStats
java -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${bamIndexStatsJar} \
INPUT=${dedupBam} \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempDir} \
> ${tmpCollectBamMetricsPrefix}.bam_index_stats

echo -e "\nBamIndexStats finished succesfull. Moving temp files to final.\n\n"
mv ${tmpCollectBamMetricsPrefix}.bam_index_stats ${dedupBam}.bam_index_stats

