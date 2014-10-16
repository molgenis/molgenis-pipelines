#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string gatkVersion
#string onekgGenomeFasta
#string indelRealignmentTargets
#string goldStandardVcf
#string goldStandardVcfIdx
#string oneKgPhase1IndelsVcf
#string oneKgPhase1IndelsVcfIdx

#string splitAndTrimBam
#string splitAndTrimBai

#string indelRealignmentDir
#string indelRealignmentBam
#string indelRealignmentBai

#pseudo from gatk forum (link: http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_indels_IndelRealigner):
#java -Xmx4g -jar GenomeAnalysisTK.jar -T IndelRealigner -R ref.fa -I input.bam -targetIntervals intervalListFromRTC.intervals -o realignedBam.bam [-known /path/to/indels.vcf] -U ALLOW_N_CIGAR_READS --allow_potentially_misencoded_quality_scores

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${indelRealignmentBam} \
 ${indelRealignmentBai}

${stage} GATK/${gatkVersion}
${checkStage}

getFile ${onekgGenomeFasta}
getFile ${splitAndTrimBam}
getFile ${splitAndTrimBai}
getFile ${indelRealignmentTargets}
getFile ${oneKgPhase1IndelsVcf}
getFile ${goldStandardVcf}
getFile ${oneKgPhase1IndelsVcfIdx}
getFile ${goldStandardVcfIdx}

if [ ! -e ${indelRealignmentDir} ]; then
	mkdir -p ${indelRealignmentDir}
fi


java -Xmx8g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T IndelRealigner \
 -R ${onekgGenomeFasta} \
 -I ${splitAndTrimBam} \
 -o ${indelRealignmentBam} \
 -targetIntervals ${indelRealignmentTargets} \
 -known ${oneKgPhase1IndelsVcf} \
 -known ${goldStandardVcf} \
 -U ALLOW_N_CIGAR_READS \
 --consensusDeterminationModel KNOWNS_ONLY \
 --LODThresholdForCleaning 0.4 \

putFile ${indelRealignmentBam}
putFile ${indelRealignmentBai}

echo "## "$(date)" ##  $0 Done "
