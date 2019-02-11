#MOLGENIS nodes=1 ppn=8 mem=12gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string RVersion
#string gatkVersion
#string onekgGenomeFasta
#string goldStandardVcf
#string goldStandardVcfIdx
#string oneKgPhase1IndelsVcf
#string oneKgPhase1IndelsVcfIdx
#string dbsnpVcf
#string dbsnpVcfIdx
#string bqsrDir
#string bqsrBam
#string bqsrBai
#string analyseCovarsDir
#string bqsrBeforeGrp
#string bqsrAfterGrp
#string analyseCovariatesPdf
#string toolDir
#string analyseCovariatesIntermediateCsv

echo "## "$(date)" Start $0"



${stage} R/${RVersion}
${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${analyseCovarsDir}

#do bqsr for covariable determination then do print reads for valid bqsrbams
#check the bqsr part and add known variants

java -Xmx6g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${bqsrBam} \
 -o ${bqsrAfterGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf} \
 -knownSites ${oneKgPhase1IndelsVcf} \
 -nct 2

java -Xmx6g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${bqsrDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T AnalyzeCovariates \
 -R ${onekgGenomeFasta} \
 -ignoreLMT \
 -before ${bqsrBeforeGrp} \
 -after ${bqsrAfterGrp} \
 -l DEBUG \
 -csv ${analyseCovariatesIntermediateCsv} \
 -plots ${analyseCovariatesPdf}

md5sum ${bqsrBeforeGrp} ${bqsrBeforeGrp}.md5
md5sum ${bqsrAfterGrp} ${bqsrAfterGrp}.md5
md5sum ${analyseCovariatesIntermediateCsv}
md5sum ${analyseCovariatesPdf}

echo "returncode: $?"; 
 
echo "## "$(date)" ##  $0 Done "
