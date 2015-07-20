#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=23:59:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
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
#string toolDir

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

getFile ${onekgGenomeFasta}
getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}

${stage} SAMtools/${samtoolsVersion}
${stage} GATK/${gatkVersion}
${checkStage}

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

if java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${splitAndTrimDir} -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
 -T SplitNCigarReads \
 -R ${onekgGenomeFasta} \
 -I ${markDuplicatesBam} \
 -o ${splitAndTrimBam} \
 -rf ReassignOneMappingQuality \
 -RMQF 255 \
 -RMQT 60 \
 -U ALLOW_N_CIGAR_READS \
 $qualAction

then
 echo "returncode: $?"; 

 putFile ${splitAndTrimBam}
 putFile ${splitAndTrimBai}
echo "md5sums"
md5sum ${splitAndTrimBam}
md5sum ${splitAndTrimBai}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
