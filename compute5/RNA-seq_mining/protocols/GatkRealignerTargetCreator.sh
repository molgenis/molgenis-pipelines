#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string gatkVersion
#string onekgGenomeFasta
#list reads2FqGz
#list splitAndTrimBam
#list splitAndTrimBai
#string indelRealignmentDir

#string goldStandardVcf
#string realignmentIntervals

#pseudo from gatk forum (link: http://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_sting_gatk_walkers_indels_RealignerTargetCreator):
#java -Xmx2g -jar GenomeAnalysisTK.jar -T RealignerTargetCreator -R ref.fasta -I input.bam -o forIndelRealigner.intervals --known /path/to/indels.vcf -U ALLOW_N_CIGAR_READS --allow_potentially_misencoded_quality_scores

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${realignmentIntervals}

${stage} GATK/${gatkVersion}
${checkStage}

getFile ${onekgGenomeFasta}
for file in "${splitAndTrimBam[@]}" "${splitAndTrimBai[@]}"; do
	echo "getFile file='$file'"
	getFile $file
done

bams=($(printf '%s\n' "${splitAndTrimBam[@]}" | sort -u ))
inputs=$(printf '-I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${indelRealignmentDir}


java -Xmx8g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -nt 4 \
 -T RealignerTargetCreator \
 -R ${onekgGenomeFasta} \
 $inputs \
 -o ${realignmentIntervals} \
 -known ${goldStandardVcf} \
 -U ALLOW_N_CIGAR_READS

putFile ${realignmentIntervals}

echo "## "$(date)" ##  $0 Done "
