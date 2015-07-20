#MOLGENIS nodes=1 ppn=2 mem=4gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string internalId
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
#string bsqrDir
#string bsqrBam
#string bsqrBai
#string analyseCovarsDir
#string bsqrBeforeGrp
#string bsqrAfterGrp
#string analyseCovariatesPdf

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

getFile ${onekgGenomeFasta}
getFile ${oneKgPhase1IndelsVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${dbsnpVcf}
getFile ${dbsnpVcfIdx}
getFile ${goldStandardVcf} 
getFile ${goldStandardVcfIdx}
getFile ${bsqrBam}
getFile ${bsqrBai}

${stage} R/${RVersion}
${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${analyseCovarsDir}

#do bsqr for covariable determination then do print reads for valid bsqrbams
#check the bsqr part and add known variants

java -Xmx4g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${bsqrDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${bsqrBam} \
 -o ${bsqrAfterGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf}\
 -knownSites ${oneKgPhase1IndelsVcf}\
 -nct 2

if java -Xmx4g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${bsqrDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T AnalyzeCovariates \
 -R ${onekgGenomeFasta} \
 -ignoreLMT \
 -before ${bsqrBeforeGrp} \
 -after ${bsqrAfterGrp} \
 -plots ${analyseCovariatesPdf} \

then
 echo "returncode: $?"; 
 
 putFile ${bsqrAfterGrp}
 putFile ${analyseCovariatesPdf}
 echo "md5sums"
 echo "${bsqrAfterGrp} - " md5sum ${bsqrAfterGrp}
 echo "${analyseCovariatesPdf} - " md5sum ${analyseCovariatesPdf}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
