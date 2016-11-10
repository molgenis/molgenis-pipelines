#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;
#use Term::ProgressBar;

#module load Term-ProgressBar/2.17-foss-2015b

####Variables
my $help;
my $VCFfile;
my $RCfile;
my $output;

####Get options
GetOptions(
                "h"                     => \$help,
                "VCF=s"                 => \$VCFfile,
                "ASEReadCounts=s"       => \$RCfile,
                "outputFile=s"          => \$output
);
usage() and exit(1) if $help;
####Obligatory args
usage() and exit(1) unless $VCFfile;
usage() and exit(1) unless $RCfile;
usage() and exit(1) unless $output;


####Open and read ASEReadCounts file, push all counts in hash
print "\n###################################################\n";
print "Processing ASEReadCounts file: $RCfile\n";
open(RC, "<$RCfile") or die("Unable to open ASEReadCounts file $RCfile"); #Read file

my %RChash;
while (my $lin=<RC>) { #Read file line by line
    chomp $lin;
    my @array = split("\t", $lin); #push line in array
    my $chr = $array[0];
    my $pos = $array[1];
    my $refCount = $array[5]; #Col 6
    my $altCount = $array[6]; #Col 7
    my $key = "$chr\t$pos";
    my $val = "$refCount,$altCount";
    $RChash{ $key } = $val; #add chr pos as key to hash, ref/alt counts are value
}
close(RC);
print "\nDone processing ASEReadCounts file\n";
print "###################################################\n";


####Open VCF file - special case for gzip
my $totalLines;
print "\n\n###################################################\n";
print "Analyzing VCF file: $VCFfile\n\n";
if ($VCFfile =~ /\.gz$/) { #Gzipped, uncompress first
    $totalLines=`zcat $VCFfile | wc -l`;
    open(VCF, "gunzip -c $VCFfile |") || die "can't open pipe to VCF file $VCFfile";
}else{ #Non compressed VCF file, just open normal
    $totalLines=`wc -l $VCFfile`;
    open(VCF, "<$VCFfile") or die("Unable to open VCF file $VCFfile"); #Read file
}


####Open output file handler
open(OUTPUT, ">$output") or die("Unable to open output file $output"); #Output file


#my $progress_bar = Term::ProgressBar->new($totalLines);
my $count=1;
####Read VCF file line by line
while (my $line=<VCF>) {
    chomp $line;
    if ($line =~ m/^#.+/gs) { #Header line, just skip
        
    }else{
        my @array = split("\t", $line); #Split line into array
        my $chr = $array[0];
        my $pos = $array[1];
        my $key = "$chr\t$pos"; #Create key to search for
        #if key exists in hash print corresponding value, otherwise just print 0,0
        if (exists $RChash{$key}) {
            print OUTPUT $RChash{$key} . "\n";
        }else{ #print 0,0
            print OUTPUT "0,0\n";
        }
    }
    #$progress_bar->update($count);
    $count++;
}

close(VCF);
close(OUTPUT);

print "\n\nDone analyzing VCF file\n";
print "###################################################\n\n";

print "\n###################################################\n\n";
print "Output written to: $output\n";
print "\n###################################################\n";


####Usage
sub usage {
        print <<EOF;
        
        
###################################################

Usage: convertASEReadCounts2CountsTable.pl

############## Obligatory parameters ##############
--VCF\t\t\tInput VCF file containing all chromosomal positions to count
--ASEReadCounts\t\tASEReadCounts file in .rtable format obtained from GATK ASEReadCounter
--outputFile\t\tOutput file containing read counts for all positions in input VCF file
###################################################


EOF
 
}
