#MOLGENIS nodes=1 ppn=8 mem=8Gb walltime=23:59:00

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



getFile ${onekgGenomeFasta}
getFile ${oneKgPhase1IndelsVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${dbsnpVcf}
getFile ${dbsnpVcfIdx}
getFile ${goldStandardVcf} 
getFile ${goldStandardVcfIdx}
getFile ${bqsrBam}
getFile ${bqsrBai}
${stage} R/${RVersion}
${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${analyseCovarsDir}

#do bqsr for covariable determination then do print reads for valid bqsrbams
#check the bqsr part and add known variants

java -Xmx6g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${bqsrDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${bqsrBam} \
 -o ${bqsrAfterGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf} \
 -knownSites ${oneKgPhase1IndelsVcf} \
 -nct 2

if java -Xmx6g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${bqsrDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T AnalyzeCovariates \
 -R ${onekgGenomeFasta} \
 -ignoreLMT \
 -before ${bqsrBeforeGrp} \
 -after ${bqsrAfterGrp} \
 -l DEBUG \
 -csv ${analyseCovariatesIntermediateCsv} \
 -plots ${analyseCovariatesPdf}

then
 echo "returncode: $?"; 
 
 putFile ${bqsrAfterGrp}
 putFile ${analyseCovariatesPdf}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
