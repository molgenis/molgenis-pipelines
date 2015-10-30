#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string sortedBam
#string sortedBai
#string samtoolsVersion
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string splitAndTrimBam
#string splitAndTrimBai
#string tmpDataDir
#string indexFile
#string tmpTmpDataDir

makeTmpDir ${splitAndTrimBam} 
tmpsplitAndTrimBam=${MC_tmpFile}

#Load Modules
${stage} ${gatkVersion}
${stage} ${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"

#it botches on base quality scores use --allow_potentially_misencoded_quality_scores / the tool is not paralel with nt/nct
qualAction=$(samtools view ${sortedBam} | \
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
echo "Running split and trim:"
if java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
 -T SplitNCigarReads \
 -R ${indexFile} \ 
 -I ${sortedBam} \ 
 -o ${tmpsplitAndTrimBam} \ 
 -rf ReassignOneMappingQuality \
 -RMQF 255 \
 -RMQT 60 \
 -U ALLOW_N_CIGAR_READS \
 $qualAction

then
	mv ${tmpsplitAndTrimBam} ${splitAndTrimBam}
    	echo "returncode: $?";
        echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

