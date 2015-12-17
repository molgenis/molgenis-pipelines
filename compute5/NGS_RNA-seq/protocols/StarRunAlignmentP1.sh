#MOLGENIS walltime=23:59:00 nodes=1 mem=40gb ppn=8

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
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
#string starAlignmentPassOneTmpDir
#string starAlignmentPassTwoTmpDir
#string sjdbFileChrStartEnd
#string sjdbOverhang
#string nTreads
#string reads1FqGz
#string reads2FqGz

## echo declared strings
#echo $stage


echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#getFile functions

getFile ${genomeEnsembleAnnotationFile}
getFile ${onekgGenomeFasta}

#Load modules
${stage} STAR/${starVersion}

#check modules
${checkStage}


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
mkdir -p ${starAlignmentPassOneTmpDir}
cd ${starAlignmentPassOneDir}


starIndexDir="${starAlignmentPassOneDir}/${genomeLatSpecies}.${genomeGrchBuild}.ensembl${ensemblVersion}.sjdbOverhang$sjdbOverhang"

if [ -d "$starIndexDir" ]; then
rm -r $starIndexDir
fi

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

cd ${starAlignmentPassOneTmpDir}

if
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

then
 echo "returncode: $?"; 

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

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
