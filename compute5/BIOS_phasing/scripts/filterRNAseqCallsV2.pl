#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;

####Variables
my $help;
my $inputFile;
my $outputFile;
my $GQ;
my $callRate;
my $removeNoGT;

####Get options
GetOptions(
                "h"                     => \$help,
                "inputFile=s"           => \$inputFile,
                "outputFile=s"          => \$outputFile,
                "genotypeQuality=s"     => \$GQ,
                "callRate:s"            => \$callRate, #optional
                "removeNoGT:s"          => \$removeNoGT #optional
);
usage() and exit(1) if $help;
####Obligatory args
usage() and exit(1) unless $inputFile;
usage() and exit(1) unless $outputFile;
usage() and exit(1) unless $GQ;



####Check if call rate is between 0 and 1, else exit with error
if (defined $callRate) {
    if ($callRate >= 0 && $callRate <= 1) {
        #Pass
    }else{
        exit("User specified option callRate is not between 0 and 1!\n");
    }
}


####Open input VCF file
print "Analyzing file: $inputFile\n";
if ($inputFile =~ /.gz$/) { #Check if input VCF file is in (b)gzip format
    open(VCF, "gunzip -c $inputFile |") || die ("Can not open pipe to $inputFile"); #Read file
}else {
    open(VCF, "<$inputFile") or die("Unable to open input file $inputFile\n"); #Read file
}


####Open output VCF file
open(OUTPUT, ">$outputFile") or die("Unable to open output file");

while (my $line=<VCF>) {
    chomp $line;
    if ($line =~ m/^#.+/gs) { #Header line, just write to output
        print OUTPUT "$line\n";
    }else{ #Variant line
        my @array = split("\t", $line); #split line
        my $lastIdx = $#array;
        my $totalNumSamples = ($lastIdx-8);
        my @arrayToPrint; #Collect output in to print later
        my $infoField = $array[7]; #Extract info column from file, 8th column
        my @infoArray = split(";",$array[7]);
        my $formatField = $array[8]; #9th column, extract format line
        my $filterVal = $array[6];
        #Extract index of DP field
        my @format = split(":", $formatField);
        my %idxGQ;
        @idxGQ{@format} = (0..$#format);
        if (exists $idxGQ{ "GQ" }) { #Check if GQ exists in format field. If not assume all calls on this specific site are ./. thus can be skipped and or also not outputted
            my $idxGQ = $idxGQ{ "GQ" };
            #Extract index of AC,AF and AN field
            my @info = split(";", $infoField);
            my @inf;
            foreach my $e (@info){
                my @ar = split("=", $e); #For each info attribute split values from it
                push(@inf, $ar[0]);
            }
            my %idxInfo;
            @idxInfo{@inf} = (0..$#inf);
            my $idxAC = $idxInfo{ "AC" };
            my $idxAF = $idxInfo{ "AF" };
            my $idxAN = $idxInfo{ "AN" };
            my $allCount = 0;
            my $allNumber = 0;
            
            my $passSamples = 0; #Use to count number of pass samples to calculate callRate later
            my $noGT = 0; #Use to count total number of no genotypes per VCF line
            #GT:AD:DP:GQ:PGT:PID:PL
            for (my $j=9; $j<= $lastIdx; $j++){ #Loop over all samples in VCF file and extract GQ
                my $val = $array[$j];
                chomp $val;
                $val =~ s/ //gs;
                my @sampleInfo = split(":", $val);
                my $lastSampleInfoIdx = $#sampleInfo;
                my $updatedSampleInfo=join(":", @sampleInfo);
                if ($lastSampleInfoIdx > 1) {
                    my $sampleGQ = $sampleInfo[$idxGQ];
                    if (defined $sampleGQ) { #Check if sample GQ indeed can be found
                        #GT field is always the first, according to VCF format specifications
                        if ($sampleGQ ne ".") { #If GQ is not . it is a value
                            if ($sampleGQ <= $GQ) { #If GQ is lower or equal to user specified GQ value, set genotype to "unknown" (./.) 
                                shift(@sampleInfo);
                                unshift(@sampleInfo, "./.");
                            }else{ #Sample GQ is sufficient enough, so count it as pass.
                                $passSamples++;
                            }
                            $updatedSampleInfo=join(":", @sampleInfo);
                            push(@arrayToPrint, $updatedSampleInfo);
                        }else{
                            push(@arrayToPrint, $array[$j]);
                        }
                    }else{
                        push(@arrayToPrint, $array[$j]);
                    }
                }else{
                    push(@arrayToPrint, $array[$j]);
                }
                
                my $sampleGT = $sampleInfo[0];
                if ($sampleGT eq "./.") { #Check if updated sample genotype is ./.
                    $noGT++;
                }
                #Count occurences of genotypes, to update allele counts and MAF later
                if ($sampleGT eq "0/0") {
                    $allNumber = ($allNumber+2);
                }elsif ($sampleGT eq "0/1"){
                    $allNumber = ($allNumber+2);
                    $allCount++;
                }elsif ($sampleGT eq "1/1"){
                    $allNumber = ($allNumber+2);
                    $allCount = ($allCount+2);
                }
            }
            
            #Calculate new MAF
            my $allAF;
            if ($allNumber == 0) { #If no genotypes observed AF will be zero
                $allAF = 0;
            }else{
                $allAF=($allCount/$allNumber);
            }
    
            #Update AC,AF and AN in info field array;
            splice(@infoArray, $idxAC, 1, "AC=$allCount");
            splice(@infoArray, $idxAF, 1, "AF=$allAF");
            splice(@infoArray, $idxAN, 1, "AN=$allNumber");
            my $infoString=join(";", @infoArray); #Join info array to string by ";" seperator
            
            #Calculate if callRate observed passes user specified threshold
            my $ratio = ($passSamples/$totalNumSamples);
            #Print output line
            
            #Check if optional "no genotype" parameter was specified and if all genotypes for a VCF line are ./.
            if (defined $removeNoGT && $totalNumSamples == $noGT) {
                #Do NOT print line
            }else{
                print OUTPUT $array[0];
                for (my $i=1; $i<=5; $i++){
                    print OUTPUT "\t" . $array[$i]; #Print first 6 columns
                }
                if (defined $callRate) { #If callRate is defined, use it for filtering
                    if ($ratio >= $callRate) {
                        $filterVal = "PASS";
                    }
                }
                print OUTPUT "\t$filterVal" . "\t" . $infoString . "\t" . $array[8];
                my $printSamples = join("\t", @arrayToPrint);
                
                #foreach my $e (@arrayToPrint){
                #    print "P: $e\n";
                #}
                
                print OUTPUT "\t$printSamples\n";
            }
        }else{ #The line doesn't contain any genotype calls, so also nog GQ value to check. Either just print it or remove it from output, depending on removeNoGT variable is set or not
            if (defined $removeNoGT) {
                #
            }else{
                print OUTPUT "$line\n";
            }
            
        }
        
    }
}

close(VCF);
close(OUTPUT);

####Usage
sub usage {
        print <<EOF;
        
        
###################################################

Usage: filterRNAseqCalls.pl

############## Obligatory parameters ##############
--inputFile\t\t\tInput VCF file to filter
--outputFile\t\t\tOutput VCF file
--genotypeQuality\t\tIndividual genotype quality (GQ) to filter on
--callRate\t\t\t[OPTIONAL] Call rate to filter SNV/SV on. When correct the FILTER column will be updated with PASS. Value within range 0-1
--removeNoGT\t\t\t[OPTIONAL] When argument is provided lines in VCF file where genotype for all samples is ./. will be removed
###################################################


EOF
 
}

