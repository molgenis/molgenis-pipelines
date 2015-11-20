#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;
use POSIX qw(ceil);
use POSIX qw(floor);

#Commandline variables
my ($help, $outputDir, $gatkVersion, $onekgGenomeFasta, $haplotyperDir, $samplesheet);

#### Get options
GetOptions(
                "h"                     => \$help,
                "samplesheet=s"         => \$samplesheet,
                "gatkVersion=s"         => \$gatkVersion,
                "onekgGenomeFasta=s"    => \$onekgGenomeFasta,
                "haplotyperDir=s"       => \$haplotyperDir,
                "outputDir=s"           => \$outputDir
          );
usage() and exit(1) if $help;
#Obligatory args
usage() and exit(1) unless $samplesheet;
usage() and exit(1) unless $gatkVersion;
usage() and exit(1) unless $outputDir;
usage() and exit(1) unless $onekgGenomeFasta;
usage() and exit(1) unless $haplotyperDir;


### For testing purpose
#/groups/umcg-wijmenga/tmp04/umcg-ndeklein/samplesheets/lld/samplesheet_lld_genotypeCalling.csv
#/groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/testParameters.csv
#/groups/umcg-wijmenga/tmp04/umcg-fvandijk/test/Public_RNA-seq_genotypeCalling/protocols/GatkMergeGvcfs.sh

### Global vars
my @indices;

### Open samplesheet.csv
open(FILE, "<$samplesheet") or die("Unable to open samplesheet: $!"); #Read file
my @file=<FILE>;
close(FILE);

### Read samplesheet header and retrieve index for needed variables
my $header = $file[0]; #Header in uppercase
chomp $header; #Header should contain these columns: internalId,project,sampleName,reads1FqGz,reads2FqGz,sortedBamFile
#Extract columns from header and use as index
my @colNames = qw(internalId project sampleName reads1FqGz reads2FqGz sortedBamFile);
getColumnIdx($header, \@colNames);
my $iIdIdx = $indices[0];
my $projectIdx = $indices[1];
my $sampleNameIdx = $indices[2];
my $r1Idx = $indices[3];
my $r2Idx = $indices[4];
my $sortedBamFileIdx = $indices[5];

### Calculate how much batches to create (N=200 samples)
my $numSamples = $#file; #Number of samples is total - headerline, is the same as returning the last Idx of the array (because we have 0 off-set)
my $numBatches = floor($numSamples / 200);
my $remaining = ($numSamples % 200);

print "Generating jobs for: $numSamples samples\nNumber of batches of 200 samples: $numBatches\nLast batch contains: $remaining samples\n";

### Generate jobs

my @samplesToAnalyze;
my $batch=0;
my $count=1;
for (my $i=1; $i<=$numSamples; $i++){
    #$count++;
    my $li = $file[$i];
    my @arr = split(",", $li);
    my $sampleName = $arr[$sampleNameIdx];
    my $project = $arr[$projectIdx];
    #my $toPush = "--variant $haplotyperDir/$sampleName.chr$chr.g.vcf";
    push(@samplesToAnalyze, $sampleName);
    if ($count == 200 || $i == $numSamples) {
        
        for (my $chr=1; $chr <=25; $chr++){
            my @samp;
            foreach my $ele (@samplesToAnalyze){
                my $toPush = "--variant $haplotyperDir/$ele.chr$chr.g.vcf";
                push(@samp, $toPush);
            }
            my $samplesString = join(" ", @samp);

my $toPrint="#!/bin/bash
#SBATCH --job-name=MergeGvcfs_batch$batch\_chr$chr
#SBATCH --output=$outputDir/MergeGvcfs_batch$batch\_chr$chr.out
#SBATCH --error=$outputDir/MergeGvcfs_batch$batch\_chr$chr.err
#SBATCH --partition=ll
#SBATCH --time=14-23:59:59
#SBATCH --cpus-per-task 8
#SBATCH --mem 32gb
#SBATCH --nodes 1
#SBATCH --open-mode=append
#SBATCH --export=NONE
#SBATCH --get-user-env=L

ENVIRONMENT_DIR=\".\"
set -e
set -u

getFile()
{
        ARGS=($@)
        NUMBER="${#ARGS[@]}";
        if [ "$NUMBER" -eq "1" ]
        then
                myFile=${ARGS[0]}

                if test ! -e $myFile;
                then
                                echo "ERROR in getFile/putFile: $myFile is missing" 1>&2
                                exit 1
                fi

        else
                echo "Example usage: getData \"\$TMPDIR/datadir/myfile.txt\""
        fi
}

putFile()
{
        `getFile $@`
}


echo \"## \"\$(date)\" Start \$0\"

#Load gatk module
module load GATK/$gatkVersion
module list

mkdir -p $haplotyperDir

inputs=\"$samplesString\"

if java -Xmx30g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=$haplotyperDir \\
-jar \$\{EBROOTGATK\}/GenomeAnalysisTK.jar \\
-T CombineGVCFs \\
-R $onekgGenomeFasta \\
-o $haplotyperDir/$project.batch$batch\_chr$chr.g.vcf \\
-L $chr \\
\$inputs 

then
 echo \"returncode: \$?\"; 

 putFile $haplotyperDir/$project.batch$batch\_chr$chr.g.vcf
cd $haplotyperDir
md5sum \$(basename $haplotyperDir/$project.batch$batch\_chr$chr.g.vcf)> \$(basename $haplotyperDir/$project.batch$batch\_chr$chr.g.vcf).md5sum
 cd -
 echo \"succes moving files\";
else
 echo \"returncode: \$?\";
 echo \"fail\";
fi

echo \"## \"\$(date)\" ##  \$0 Done \"


";

        open(OUTPUT, ">$outputDir/MergeGvcfs_batch$batch\_chr$chr.sh") or die("Unable to open outputfile: $!"); #Read file
        print OUTPUT $toPrint;
        close(OUTPUT);

        }
        $batch++;
        $count=1;
        undef(@samplesToAnalyze);
    }
    $count++;
}


### SUBS ### SUBS ### SUBS ### SUBS ### SUBS ### SUBS ### SUBS ### SUBS ###

### Grep column indices and push into array
sub getColumnIdx {
    my $header = shift;
    my ($colnames) = @_;
    my @headerarray = split(",", $header);
    undef(@indices);
    foreach my $columnName (@$colnames){
        my( $idx )= grep { $headerarray[$_] eq $columnName } 0..$#headerarray;
        push(@indices, $idx);
    }
    return(@indices);
}

### Usage of software
sub usage {
        print <<EOF;

#########################################################################################################
generateMergeGenotypeGvcfJobsV3
#########################################################################################################

Usage: ./generateMergeGenotypeGvcfJobsV3.pl <samplesheet.csv> <gatkVersion> <oneKgGenomeFasta>
<haplotyperDir> <outputJobDirectory>

-h\t\t\tThis manual.
-samplesheet\t\tPath to samplesheet.csv
-gatkVersion\t\tThe GATK module version to use
-onekgGenomeFasta\tPath to the reference genome fasta file to use
-haplotyperDir\t\tDirectory in which the input gVCF files are located. The merged
\t\t\toutput project gVCF file is also written to this directory, using the
\t\t\t"project" name as defined in the samplesheet.csv
-outputDir\t\tPath to output directory for jobs

#########################################################################################################

EOF
 
}
