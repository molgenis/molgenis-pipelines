#MOLGENIS nodes=1 ppn=8 mem=10gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
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
#string toolDir

#pseudo from gatk forum (link: http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_indels_IndelRealigner):
#java -Xmx4g -jar GenomeAnalysisTK.jar -T IndelRealigner -R ref.fa -I input.bam -targetIntervals intervalListFromRTC.intervals -o realignedBam.bam [-known /path/to/indels.vcf] -U ALLOW_N_CIGAR_READS --allow_potentially_misencoded_quality_scores

echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}



if [ ! -e ${indelRealignmentDir} ]; then
	mkdir -p ${indelRealignmentDir}
fi


java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
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

echo "returncode: $?"; 

echo "## "$(date)" ##  $0 Done "
