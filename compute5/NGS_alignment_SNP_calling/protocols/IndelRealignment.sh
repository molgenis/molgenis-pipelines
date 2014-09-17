#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string dedupBam
#string dedupBamIdx
#string tempDir
#string intermediateDir
#string indexFile
#string realignedBam
#string realignedBamIdx
#string indelRealignmentTargetIntervals
#string KGPhase1IndelsVcf
#string KGPhase1IndelsVcfIdx
#string MillsGoldStandardIndelsVcf
#string MillsGoldStandardIndelsVcfIdx


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "dedupBam: ${dedupBam}"
echo "dedupBamIdx: ${dedupBamIdx}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "realignedBam: ${realignedBam}"
echo "realignedBamIdx: ${realignedBamIdx}"
echo "indelRealignmentTargetIntervals: ${indelRealignmentTargetIntervals}"
echo "KGPhase1IndelsVcf: ${KGPhase1IndelsVcf}"
echo "KGPhase1IndelsVcfIdx: ${KGPhase1IndelsVcfIdx}"
echo "MillsGoldStandardIndelsVcf: ${MillsGoldStandardIndelsVcf}"
echo "MillsGoldStandardIndelsVcfIdx: ${MillsGoldStandardIndelsVcfIdx}"


sleep 10

#Check if output exists
alloutputsexist \
"${realignedBam}" \
"${realignedBamIdx}"

#Get dedupped BAM file and reference data
getFile ${dedupBam}
getFile ${dedupBamIdx}
getFile ${indexFile}
getFile ${indelRealignmentTargetIntervals}
getFile ${KGPhase1IndelsVcf}
getFile ${KGPhase1IndelsVcfIdx}
getFile ${MillsGoldStandardIndelsVcf}
getFile ${MillsGoldStandardIndelsVcfIdx}

makeTmpDir ${realignedBam}
tmpRealignedBam=${MC_tmpFile}

makeTmpDir ${realignedBamIdx}
tmpRealignedBamIdx=${MC_tmpFile}

#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

#Run GATK on knowns only
#Only use --fix_misencoded_quality_scores to fix misencoded quality scores on the fly (Automatically substracts 31 from Illumina Qscores and writes corrected Qscores away.)
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T IndelRealigner \
-I ${dedupBam} \
-R ${indexFile} \
-targetIntervals ${indelRealignmentTargetIntervals} \
-known ${KGPhase1IndelsVcf} \
-known ${MillsGoldStandardIndelsVcf} \
--consensusDeterminationModel KNOWNS_ONLY \
-LOD 0.4 \
-o ${tmpRealignedBam}



echo -e "\nIndelRealignment finished succesfull. Moving temp files to final.\n\n"
mv ${tmpRealignedBam} ${realignedBam}
mv ${tmpRealignedBamIdx} ${realignedBamIdx}
putFile "${realignedBam}"
putFile "${realignedBamIdx}"

