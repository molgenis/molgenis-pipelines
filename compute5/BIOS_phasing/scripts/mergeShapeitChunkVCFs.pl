#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use List::Util qw(min max);
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;


for (my $i=1; $i<=22; $i++){
my $CHR = "$i";
my $outputFile = "/groups/umcg-bios/tmp03/projects/phasing/results_GQ20/shapeitSmallChunksVcfs/BIOS_freeze2.chr$CHR.concatenated.shapeit.phased.vcf.gz";

#Retrieve header
my $header = `zcat /groups/umcg-bios/tmp03/projects/phasing/results_GQ20//shapeitSmallChunksVcfs/chr1/BIOS_freeze2.chr1.156776035.157015162.shapeit.phased.vcf.gz | head -200 | grep "^#"`;
chomp($header);

open(INPUT, "< /home/umcg-fvandijk/outputChromosomeChunksShapeitNiek.txt") || die "can�t open input file!\n";
open(OUTPUT, "> $outputFile") || die "can�t open output file!\n";
print OUTPUT "$header\n";
#CHR,chromosomeChunk
#1,1:1-134836    1:11869-29806
while (my $line = <INPUT>){
    chomp($line);
    if ($line =~ m/^$CHR,$CHR:.+/gs){ #Chromosome line of interest, try to gather variants for chunk and merge
        my @array = split("\t", $line);
        my $fileOI = $array[0];
        my $coordOI = $array[1];
        my $fileStart;
        my $fileEnd;
        my $chunkStart;
        my $chunkEnd;
        if ($fileOI =~ m/^$CHR,$CHR:([0-9]{1,})-([0-9]{1,})/gs) {
            $fileStart = $1;
            $fileEnd = $2;
        }
        if ($coordOI =~ m/^$CHR:([0-9]{1,})-([0-9]{1,})/gs) {
            $chunkStart = ($1-50);
            $chunkEnd = ($2+50);
        }
        #print "$fileStart-$fileEnd\t$chunkStart-$chunkEnd\n";
        #Retrieve all variants in specified region (+50bp flanking) from corresponding VCF file using tabix
        my $searchVCF = "/groups/umcg-bios/tmp03/projects/phasing/results_GQ20//shapeitSmallChunksVcfs/chr$CHR/BIOS_freeze2.chr$CHR.$fileStart.$fileEnd.shapeit.phased.vcf.gz";
        my $grepVCF = `tabix $searchVCF $CHR:$chunkStart-$chunkEnd`;
        if (defined $grepVCF && $grepVCF ne "") {
            chomp($grepVCF);
            print OUTPUT "$grepVCF\n";
        }else{
            print "Can not find any variants in file: $searchVCF using search coordinates: $CHR:$chunkStart-$chunkEnd\n";
        }
    }
}
close(OUTPUT);
close(INPUT);

`bgzip $outputFile`;
`tabix $outputFile.gz`;
}