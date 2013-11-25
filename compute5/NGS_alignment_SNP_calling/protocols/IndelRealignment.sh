#MOLGENIS walltime=35:59:00 mem=4gb

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
#string tmpRealignedBam
#string tmpRealignedBamIdx
#string realignedBam
#string realignedBamIdx
#string indelRealignmentTargetIntervals
#string KGPhase1IndelsVcf
#string MillsGoldStandardIndelsVcf


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
echo "tmpRealignedBam: ${tmpRealignedBam}"
echo "tmpRealignedBamIdx: ${tmpRealignedBamIdx}"
echo "realignedBam: ${realignedBam}"
echo "realignedBamIdx: ${realignedBamIdx}"
echo "indelRealignmentTargetIntervals: ${indelRealignmentTargetIntervals}"
echo "KGPhase1IndelsVcf: ${KGPhase1IndelsVcf}"
echo "MillsGoldStandardIndelsVcf: ${MillsGoldStandardIndelsVcf}"


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
getFile ${MillsGoldStandardIndelsVcf}


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

#Run GATK on knowns only, fix misencoded quality scores on the fly (Automatically substracts 31 from Illumina Qscores and writes corrected Qscores away.)
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T IndelRealigner \
--fix_misencoded_quality_scores \
-I ${dedupBam} \
-R ${indexFile} \
-targetIntervals ${indelRealignmentTargetIntervals} \
-known ${KGPhase1IndelsVcf} \
-known ${MillsGoldStandardIndelsVcf} \
--consensusDeterminationModel KNOWNS_ONLY \
-LOD 0.4 \
-o ${tmpRealignedBam}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode IndelRealignment: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nIndelRealignment finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpRealignedBam} ${realignedBam}
    mv ${tmpRealignedBamIdx} ${realignedBamIdx}
    putFile "${realignedBam}"
    putFile "${realignedBamIdx}"
    
else
    echo -e "\nFailed to move IndelRealignment results to ${intermediateDir}\n\n"
    exit -1
fi
