#MOLGENIS nodes=1 ppn=8 mem=14gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string samtoolsVersion
#string gatkVersion
#string onekgGenomeFasta
#string goldStandardVcf
#string goldStandardVcfIdx
#string oneKgPhase1IndelsVcf
#string oneKgPhase1IndelsVcfIdx
#string dbsnpVcf
#string dbsnpVcfIdx
#string indelRealignmentBam
#string indelRealignmentBai
#string bqsrDir
#string bqsrBam
#string bqsrBai
#string bqsrBeforeGrp
#string toolDir

#pseudo from gatk forum (link: http://gatkforums.broadinstitute.org/discussion/3891/best-practices-for-variant-calling-on-rnaseq):
#java -jar GenomeAnalysisTK.jar -T SplitNCigarReads -R ref.fasta -I dedupped.bam -o split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

echo "## "$(date)" Start $0"



${stage} GATK/${gatkVersion}
${checkStage}


mkdir -p ${bqsrDir}

#do bqsr for covariable determination then do print reads for valid bqsrbams
#check the bqsr part and add known variants

java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bqsrBeforeGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf}\
 -knownSites ${oneKgPhase1IndelsVcf}\
 -nct 2

java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bqsrBam} \
 -BQSR ${bqsrBeforeGrp} \
 -nct 2

echo "returncode: $?"; 

cd ${bqsrDir}
md5sum $(basename ${bqsrBam})> $(basename ${bqsrBam}).md5
md5sum $(basename ${bqsrBam%bam}bai)> $(basename ${bqsrBam%bam}bai).md5
cd -

echo "## "$(date)" ##  $0 Done "
