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
#string indelRealignmentTargetIntervals
#string KGPhase1IndelsVcf
#string KGPhase1IndelsVcfIdx
#string MillsGoldStandardIndelsVcf
#string MillsGoldStandardIndelsVcfIdx
#string tmpDataDir
#string project

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "gatkVersion: ${gatkVersion}"
echo "gatkJar: ${gatkJar}"
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

makeTmpDir ${realignedBam}
tmpRealignedBam=${MC_tmpFile}

makeTmpDir ${realignedBamIdx}
tmpRealignedBamIdx=${MC_tmpFile}

#Load GATK module
${stage} GATK/${gatkVersion}
${checkStage}

#Run GATK on knowns only
#Only use --fix_misencoded_quality_scores to fix misencoded quality scores on the fly (Automatically substracts 31 from Illumina Qscores and writes corrected Qscores away.)
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${gatkJar} \
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


