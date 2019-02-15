#MOLGENIS nodes=1 ppn=8 mem=10gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string samtoolsVersion
#string gatkVersion
#string markDuplicatesBam
#string markDuplicatesBai
#string onekgGenomeFasta

#string splitAndTrimBam
#string splitAndTrimBai
#string splitAndTrimDir
#string toolDir

echo "## "$(date)" Start $0"



${stage} SAMtools/${samtoolsVersion}
${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${splitAndTrimDir}

java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T SplitNCigarReads \
 -R ${onekgGenomeFasta} \
 -I ${markDuplicatesBam} \
 -o ${splitAndTrimBam} \
 -rf ReassignOneMappingQuality \
 -RMQF 255 \
 -RMQT 60 \
 -U ALLOW_N_CIGAR_READS

echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "
