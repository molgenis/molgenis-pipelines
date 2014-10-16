#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string samtoolsVersion
#string gatkVersion
#string markDuplicatesBam
#string markDuplicatesBai
#string onekgGenomeFasta

#string splitAndTrimBam
#string splitAndTrimBai
#string splitAndTrimDir

#pseudo from gatk forum (link: http://gatkforums.broadinstitute.org/discussion/3891/best-practices-for-variant-calling-on-rnaseq):
#java -jar GenomeAnalysisTK.jar -T SplitNCigarReads -R ref.fasta -I dedupped.bam -o split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${splitAndTrimBam}

${stage} samtools/${samtoolsVersion}
${stage} GATK/${gatkVersion}
${checkStage}

getFile ${onekgGenomeFasta}
getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}

mkdir -p ${splitAndTrimDir}

#it botches on base quality scores use --allow_potentially_misencoded_quality_scores / the tool is not paralel with nt/nct
qualAction=$(samtools view ${markDuplicatesBam} | \
 head -1000000 | \
 awk '{gsub(/./,"&\n",$11);print $11}'| \
 sort -u| \
 perl -wne '
 $_=ord($_);
 print $_."\n"if(not($_=~/10/));' | \
 sort -n | \
 perl -wne '
 use strict;
 use List::Util qw/max min/;
 my @ords=<STDIN>;
 if(min(@ords) >= 59 && max(@ords) <=104 ){
	print " --fix_misencoded_quality_scores ";
	warn "Illumina <= 1.7 scores detected using:--fix_misencoded_quality_scores.\n";
 }elsif(min(@ords) >= 33 && max(@ords) <= 74){
	print " ";
	warn "quals > illumina 1.8 detected no action to take.\n";
 }elsif(min(@ords) >= 33 && max(@ords) <= 80){
	print " --allow_potentially_misencoded_quality_scores "; 
	warn "Strange illumina like quals detected using:--allow_potentially_misencoded_quality_scores."
 }else{
	die "Cannot estimate quality scores here is the list:".join(",",@ords)."\n";
 }
')
echo
echo "## Action to perform in quals: "$qualAction" ##"
echo

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T SplitNCigarReads \
 -R ${onekgGenomeFasta} \
 -I ${markDuplicatesBam} \
 -o ${splitAndTrimBam} \
 -rf ReassignOneMappingQuality \
 -RMQF 255 \
 -RMQT 60 \
 -U ALLOW_N_CIGAR_READS \
 $qualAction

putFile ${splitAndTrimBam}
putFile ${splitAndTrimBai}

echo "## "$(date)" ##  $0 Done "
