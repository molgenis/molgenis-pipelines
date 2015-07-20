#MOLGENIS nodes=1 ppn=2 mem=4gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string internalId
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
#string bsqrDir
#string bsqrBam
#string bsqrBai
#string bsqrBeforeGrp

#pseudo from gatk forum (link: http://gatkforums.broadinstitute.org/discussion/3891/best-practices-for-variant-calling-on-rnaseq):
#java -jar GenomeAnalysisTK.jar -T SplitNCigarReads -R ref.fasta -I dedupped.bam -o split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

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

mkdir -p ${bsqrDir}

#do bsqr for covariable determination then do print reads for valid bsqrbams
#check the bsqr part and add known variants

java -Xmx4g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${bsqrDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bsqrBeforeGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf}\
 -knownSites ${oneKgPhase1IndelsVcf}\
 -nct 2

if java -Xmx4g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${bsqrDir} -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bsqrBam} \
 -BQSR ${bsqrBeforeGrp} \
 -nct 82

then
 echo "returncode: $?"; 

 putFile ${bsqrBam}
 putFile ${bsqrBai}
 putFile ${bsqrBeforeGrp}
 echo "md5sums"
 echo "${bsqrBam} - " md5sum ${bsqrBam}
 echo "${bsqrBai} - " md5sum ${bsqrBai}
 echo "${bsqrBeforeGrp} - " md5sum ${bsqrBeforeGrp}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
