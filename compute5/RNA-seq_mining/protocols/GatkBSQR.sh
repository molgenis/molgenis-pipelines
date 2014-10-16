#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
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

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${bsqrBam} \
 ${bsqrBai}


${stage} GATK/${gatkVersion}
${checkStage}

getFile ${onekgGenomeFasta}
getFile ${oneKgPhase1IndelsVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${dbsnpVcf}
getFile ${dbsnpVcfIdx}
getFile ${goldStandardVcf} 
getFile ${goldStandardVcfIdx}
getFile ${indelRealignmentBam}
getFile ${indelRealignmentBai}

mkdir -p ${bsqrDir}

#do bsqr for covariable determination then do print reads for valid bsqrbams
#check the bsqr part and add known variants

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T BaseRecalibrator\
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bsqrBeforeGrp} \
 -knownSites ${dbsnpVcf} \
 -knownSites ${goldStandardVcf}\
 -knownSites ${oneKgPhase1IndelsVcf}\
 -nct 8

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R ${onekgGenomeFasta} \
 -I ${indelRealignmentBam} \
 -o ${bsqrBam} \
 -BQSR ${bsqrBeforeGrp} \
 -nct 8 

putFile ${bsqrBam}
putFile ${bsqrBai}
putFile ${bsqrBeforeGrp}

echo "## "$(date)" ##  $0 Done "
