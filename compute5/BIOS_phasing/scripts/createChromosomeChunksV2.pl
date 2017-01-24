#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use List::Util qw(min max);
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;

#perl createChromosomeChunks.pl -gtfFile /apps/data/ftp.ensembl.org/pub/release-75/gtf/homo_sapiens/Homo_sapiens.GRCh37.75.gtf -dictFile /apps/data/ftp.broadinstitute.org/bundle/2.8/b37/human_g1k_v37.dict -geneFile expressedGenesBloodPatrick20170118.txt -outputFile output.txt

####Variables
my $help;
my $gtfFile;
my $dictFile;
my $geneFile;
my $output;

####Get options
GetOptions(
                "h"                     => \$help,
                "gtfFile=s"             => \$gtfFile,
                "dictFile=s"            => \$dictFile,
                "geneFile=s"            => \$geneFile,
                "outputFile=s"          => \$output
);
usage() and exit(1) if $help;
####Obligatory args
usage() and exit(1) unless $gtfFile;
usage() and exit(1) unless $dictFile;
usage() and exit(1) unless $geneFile;
usage() and exit(1) unless $output;


#Read dictionaryFile
print "\n\n\n###################################################\n";
print "\nReading dictFile: $dictFile ..\n";
my %dict;
open(DICT, "< $dictFile") or die("Unable to open dictFile $dictFile"); #Read file
while (my $li = <DICT>) {
    chomp $li;
    if ($li =~ m/\@SQ\tSN:(.+)\tLN:(.+)\tUR:.+/gs) { #Extract chromosome number and length from dictionary lines
        my $chr = $1;
        $chr =~ s/X/23/g;
        $chr =~ s/Y/24/g;
        my $length = $2;
        $dict{ $chr } = $length;
    }
}
close(DICT);
print "Done reading dictFile";
print "\n###################################################\n";


#Read geneFile
print "\n\n\n###################################################\n";
print "\nReading geneFile: $geneFile ..\n";
my %genes;
open(GENE, "< $geneFile") or die("Unable to open geneFile $geneFile"); #Read file
while (my $lin = <GENE>) {
    chomp $lin;
    $genes{ $lin } = $lin;
}
close(GENE);
print "Done reading geneFile";
print "\n###################################################\n";


#Read GTF file
my %HoHgene; #Create hash of hashes to store all coordinates per chromosome
my %HoHend;
print "\n\n\n###################################################\n";
print "\nReading gtfFile: $gtfFile ..\n";
open(GTF, "< $gtfFile") or die("Unable to open samplesheet $gtfFile"); #Read file
while (my $line = <GTF>) {
    chomp $line;
    #Read line, extract chr,�start pos, end pos, Ensembl Gene Symbol from gene features only
    if ($line !~ m/^#.+/gs) { #Check if line starts with # symbole, if not it's not a header line
        my @array = split("\t", $line);
        my $chr = $array[0];
        $chr =~ s/X/23/g;
        $chr =~ s/Y/24/g;
        my $feature = $array[2];
        my $start = $array[3];
        my $end = $array[4];
        my $featureInfo = $array[8];
        my $geneID;
        #Extract Ensembl gene symbol from featureInfo line
        if ($featureInfo =~ m/.+ene_id "(ENSG[0-9]{1,})";.+/gs) {
            $geneID = $1;
        }
        if ($feature eq "gene") {
        #print "$chr\t$start\t$end\t$feature\t$geneID\n";
            if (exists $genes{ $geneID }) { #Check if this gene symbol exists in user defined list, if so add it to the list
                $HoHgene{$chr}{$start} = $geneID; #Format: HoH{who}{key}={value};
                $HoHend{$chr}{$start} = $end;
            }
        }
    }
}
print "Done reading gtfFile";
print "\n###################################################\n";


#Produce output file
print "\n\n\n###################################################\n";
print "\nGenerating outputFile: $output ..\n";
open(OUTPUT, "> $output") or die("Unable to open outputFile $output"); #Read file
print OUTPUT "CHR,chromosomeChunk\n"; #Header for output file

my %HoHchunkLengths;
for (my $i=1; $i <= 22; $i++){ #Iterate over all chromosomes, 1 to 22
    print "Processing chromosome $i ..\n";
    my $chr = $i;
    my @starts;
    my @ends;
    my %chunkLengths;
    for my $keyStart (sort {$a<=>$b} keys %{ $HoHgene{$i} }){ #Do the sorting per chromosome, also write results per chromosome
        #my $geneID = $HoHgene{$i}{$keyStart};
        my $end = $HoHend{$chr}{$keyStart};
        push(@starts, $keyStart);
        push(@ends, $end);
    }
    
    #Check all regions for overlap with each other. If there is overlap merge the regions
    my @ranges;
    while ( @starts && @ends ) { #Put all starts and ends in array REF
        my $s = shift @starts;
        my $e = shift @ends;
        push @ranges, [ $s, $e ]; #Create ranges in arrayREF
    }
    
    my @merged_ranges;
    push @merged_ranges, shift @ranges;
    
    foreach my $range (@ranges) { #Determine if there is overlap
        my $overlap = 0;
        foreach my $m_range (@merged_ranges) { #For every range determine overlap
            if ( ranges_overlap($range,$m_range) ) {
                $overlap = 1;
                $m_range = merge_range($range,$m_range);
            }
        }
        if ( !$overlap ) {
            push @merged_ranges, $range;
        }
    }
    
    my @Starts;
    my @Ends;
    foreach my $range (@merged_ranges) { #Push results in new arrays to use for downstream printing to output
        push(@Starts, $range->[0]);
        push(@Ends, $range->[1]);
    }

    #Print output list
    my $lastIdx = $#Starts;
    for (my $k=0; $k <= $lastIdx; $k++){ #Iterate over final arrays, printing the new regions
        my $length;
        my $currStart = $Starts[$k];
        my $currEnd = $Ends[$k];
        my $prevStart = $Starts[$k-1];
        my $prevEnd = $Ends[$k-1];
        my $nextStart = $Starts[$k+1];
        my $nextEnd = $Ends[$k+1];
        my $startToPrint = $currStart;
        my $endToPrint = $currEnd;
        if ($k == 0) { #First element, don't check for previous gene
            $startToPrint = 1;
            $endToPrint = $nextEnd;
        }elsif ($k == $lastIdx){ #Check if last element, write start from previous gene and end of the chromosome as coordinates
            my $chrEnd = $dict{ $chr }; #Extract end position of chromosome
            $startToPrint = $prevStart;
            $endToPrint = $chrEnd;
        }else{ #Region is not first or last, so just take the boundaries of flanking genes
            $startToPrint = $prevStart;
            $endToPrint = $nextEnd;
        }
        print OUTPUT "$chr,$chr:$startToPrint-$endToPrint\n";
        $length=($endToPrint-$startToPrint);
        $chunkLengths{ $length }++;
    }
    
    for my $key (sort {$a<=>$b} keys %chunkLengths){
        my $val = $chunkLengths{ $key };
        #print "$chr\t$key\t$val\n";
        #`echo -e -n "$chr\t$key\t$val\n" > ./chunkLengths.txt`;
    }
    
}
close(OUTPUT);
print "Done generating outputFile";
print "\n###################################################\n";



####SUBROUTINES####
sub ranges_overlap { #Subroutine to check for overlap
    my $r1 = shift;
    my $r2 = shift;

    return ( $r1->[0] <= $r2->[1] && $r2->[0] <= $r1->[1] );
}

sub merge_range { #Subroutine to merge overlapping regions
    my $r1 = shift;
    my $r2 = shift;
    use List::Util qw/ min max/;

    my $merged = [ min($r1->[0],$r2->[0]), max($r1->[1],$r2->[1]) ];
    return $merged;
}

####Usage
sub usage {
        print <<EOF;
        
        
###################################################

This script generates overlapping chromosome chunks
for all autosomal chromosomes, to be used in
"shape-it call".

###################################################

Usage: createChromosomeChunks.pl

Author: f.van.dijk @ UMCG

############## Obligatory parameters ##############
--help\t\tThis manual
--gtfFile\tInput GTF file to merge genes from.
--dictFile\tInput dictionary file belonging to
\t\treference fasta file.
--geneFile\tInput file containing expressed genes
\t\tto create chunks from.
\t\t !! One Ensembl gene symbol per line !! 
--outputFile\tOutput file containing chunks.
###################################################


EOF
 
}
