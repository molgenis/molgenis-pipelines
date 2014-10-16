#MOLGENIS walltime=35:59:00 nodes=1 mem=30gb ppn=8

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string intermediateDir
#string resDir
#string toolDir
#string genomeLatSpecies
#string genomeBuild
#string genomeGrchBuild
#string ensemblVersion
#string onekgGenomeFasta
#string genomeEnsembleAnnotationFile
#string starAlignmentDir 
#string starAlignmentPassOneDir
#string starAlignmentPassTwoDir
#string sjdbFileChrStartEnd
#string sjdbOverhang
#string nTreads
#string reads1FqGz
#string reads2FqGz

## echo declared strings
#echo $stage


echo "## "$(date)" ##  $0 Started "

#Check if output exists if so execute 'exit -0'
alloutputsexist \
 ${starAlignmentPassOneDir}/Aligned.out.sam \
 ${starAlignmentPassOneDir}/Log.final.out \
 ${starAlignmentPassOneDir}/Log.out \
 ${starAlignmentPassOneDir}/Log.progress.out \
 ${starAlignmentPassOneDir}/SJ.out.tab

#getFile functions

getFile ${genomeEnsembleAnnotationFile}
getFile ${onekgGenomeFasta}

#Load modules
${stage} STAR/${starVersion}

#check modules
${checkStage}

set -x
set -e

if [ -e ${starAlignmentPassOneDir}/Aligned.out.sam ]; then

	echo "Aligned.out.sam already present in '"$(pwd)"' skipping alignment"
	exit 0
fi

#read length parameters on the fly

if [ ${#reads2FqGz} -eq 0 ]; then
	getFile ${reads1FqGz}
	echo "## "$(date)" ## Single-end readlength test"
	readLength=$(gzip -dc ${reads1FqGz} | \
		head -10000 | \
		perl -we 'use strict;use List::Util qw/max/; my $in;$in=*STDIN; my @l;while(<$in>){chomp;my $line = $_;  push(@l, length($line)) if(($. % 4 )==2);}; my $sjboh=(max(@l)); print $sjboh."\n"')
else
	getFile ${reads1FqGz}
	getFile ${reads2FqGz}
	echo "## "$(date)" ## Paired-end readlength test"
	
	readLength1=$(gzip -dc ${reads1FqGz} | \
		head -10000 | \
		perl -we 'use strict;use List::Util qw/max/; my $in;$in=*STDIN; my @l;while(<$in>){chomp;my $line = $_;  push(@l, length($line)) if(($. % 4 )==2);}; my $sjboh=(max(@l)); print $sjboh."\n"')
	
	readLength2=$(gzip -dc ${reads2FqGz} | \
		head -10000 | \
		perl -we 'use strict;use List::Util qw/max/; my $in;$in=*STDIN; my @l;while(<$in>){chomp;my $line = $_;  push(@l, length($line)) if(($. % 4 )==2);}; my $sjboh=(max(@l)); print $sjboh."\n"')
	#for sjdbOverhang the best thing to use is max read length -1: shorter than max read length migth result in sloppy alignments near intron-exon borders but possibly better mapq. max read length migth result into good alignments near intron-exon borders but possibly worse mapq for shorter reads.
	if [  $readLength1 -le  $readLength2 ]; then 
		let 'sjdbOverhang=readLength2 - 1'
	elif [  $readLength1 -gt  $readLength2 ]; then 
		let 'sjdbOverhang=readLength1 - 1'
	fi
fi
echo "## "$(date)" ##sjdbOverhang determined. sjdbOverhang=$sjdbOverhang"




#generate index for star...

mkdir -p ${starAlignmentPassOneDir}
cd ${starAlignmentPassOneDir}


starIndexDir=${starAlignmentPassOneDir}/${genomeLatSpecies}.${genomeGrchBuild}.ensembl${ensemblVersion}.sjdbOverhang$sjdbOverhang

mkdir -p $starIndexDir

echo "## "$(date)" ##  genomeGenerate to $starIndexDir"
	
STAR \
 --runMode genomeGenerate \
 --genomeDir $starIndexDir \
 --genomeFastaFiles ${onekgGenomeFasta} \
 --sjdbGTFfile ${genomeEnsembleAnnotationFile} \
 --sjdbOverhang $sjdbOverhang \
 --runThreadN $nTreads

##run alignment

if [ ${#reads2FqGz} -eq 0 ]; then 

	echo "## "$(date)" ## Single-end Alignment"
	
	STAR \
	 --genomeDir $starIndexDir \
	 --readFilesIn ${reads1FqGz} \
	 --runThreadN $nTreads \
	 --readFilesCommand "zcat " \
	 --chimSegmentMin 15 \
	 --chimJunctionOverhangMin 15
else

	echo "## "$(date)" ##  Paired-end Alignment"

	STAR \
	 --genomeDir $starIndexDir \
	 --readFilesIn ${reads1FqGz} ${reads2FqGz} \
	 --runThreadN $nTreads \
	 --readFilesCommand "zcat " \
	 --chimSegmentMin 15 \
	 --chimJunctionOverhangMin 15
fi
cd $OLDPWD

#remove starindexdir
ls -alh $starIndexDir
echo
du -h $starIndexDir
echo "## "$(date)" ## Removing starindexdir:"$starIndexDir" because ~27 gb" 
rm -rv $starIndexDir



putFile ${starAlignmentPassOneDir}/Aligned.out.sam
putFile ${starAlignmentPassOneDir}/Log.final.out
putFile ${starAlignmentPassOneDir}/Log.out
putFile ${starAlignmentPassOneDir}/Log.progress.out
putFile ${sjdbFileChrStartEnd} 
#aka ${starAlignmentPassOneDir}/SJ.out.tab

#filter awk '{if($5>0 && $1 != "M" && $1 != "MT" ){print $0}}' ${sjdbFileChrStartEnd} ?

echo "## "$(date)" ##  $0 Done "

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi
