#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
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

#string bsqrDir
#string bsqrBam
#string bsqrBai

#string analyseCovarsDir
#string bsqrBeforeGrp
#string bsqrAfterGrp
#string analyseCovariatesPdf
echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${bsqrAfterGrp}
 ${analyseCovariatesPdf} 

${stage} R/${RVersion}
${stage} GATK/${gatkVersion}
${checkStage}

getFile ${onekgGenomeFasta}
getFile ${oneKgPhase1IndelsVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${dbsnpVcf}
getFile ${dbsnpVcfIdx}
getFile ${goldStandardVcf} 
getFile ${goldStandardVcfIdx}
getFile ${bsqrBam}
getFile ${bsqrBai}

mkdir -p ${analyseCovarsDir}

#do bsqr for covariable determination then do print reads for valid bsqrbams
#check the bsqr part and add known variants

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${bsqrBam} \
 -o ${bsqrAfterGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf}\
 -knownSites ${oneKgPhase1IndelsVcf}\
 -nct 8

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T AnalyzeCovariates \
 -R ${onekgGenomeFasta} \
 -ignoreLMT \
 -before ${bsqrBeforeGrp} \
 -after ${bsqrAfterGrp} \
 -plots ${analyseCovariatesPdf} \

putFile ${bsqrAfterGrp}
putFile ${analyseCovariatesPdf}

echo "## "$(date)" ##  $0 Done "
