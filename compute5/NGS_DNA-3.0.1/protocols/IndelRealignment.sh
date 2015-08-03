#MOLGENIS walltime=23:59:00 mem=4gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string dedupBam
#string dedupBamIdx
#string tempDir
#string intermediateDir
#string indexFile
#string realignedBam
#string realignedBamIdx
#string MillsGoldStandardChr1Intervals
#string KGPhase1IndelsVcf
#string KGPhase1IndelsVcfIdx
#string MillsGoldStandardIndelsVcf
#string tmpDataDir
#string project

makeTmpDir ${realignedBam}
tmpRealignedBam=${MC_tmpFile}

makeTmpDir ${realignedBamIdx}
tmpRealignedBamIdx=${MC_tmpFile}

#Load GATK module
${stage} ${gatkVersion}
${checkStage}

#Run GATK on knowns only
#Only use --fix_misencoded_quality_scores to fix misencoded quality scores on the fly (Automatically substracts 31 from Illumina Qscores and writes corrected Qscores away.)
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
${EBROOTGATK}/${gatkJar} \
-T IndelRealigner \
-I ${dedupBam} \
-R ${indexFile} \
-targetIntervals ${MillsGoldStandardChr1Intervals} \
-known ${KGPhase1IndelsVcf} \
-known ${MillsGoldStandardIndelsVcf} \
--consensusDeterminationModel KNOWNS_ONLY \
-LOD 0.4 \
-o ${tmpRealignedBam}

echo -e "\nIndelRealignment finished succesfull. Moving temp files to final.\n\n"
mv ${tmpRealignedBam} ${realignedBam}
mv ${tmpRealignedBamIdx} ${realignedBamIdx}


