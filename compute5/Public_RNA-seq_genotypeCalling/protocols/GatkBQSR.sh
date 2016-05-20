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


getFile ${onekgGenomeFasta}
getFile ${oneKgPhase1IndelsVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${dbsnpVcf}
getFile ${dbsnpVcfIdx}
getFile ${goldStandardVcf} 
getFile ${goldStandardVcfIdx}
getFile ${indelRealignmentBam}
getFile ${indelRealignmentBai}

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

if java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bqsrBam} \
 -BQSR ${bqsrBeforeGrp} \
 -nct 2

then
 echo "returncode: $?"; 

 putFile ${bqsrBam}
 putFile ${bqsrBai}
 putFile ${bqsrBeforeGrp}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
