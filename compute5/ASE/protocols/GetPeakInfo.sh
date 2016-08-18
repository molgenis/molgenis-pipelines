#!bin/bash
module load BEDTools
module load tabix
# Generates Exon Information Files
# I: $1 Reference sequence in FASTA fromat .fa $2 Peaks file in .bed FROM HOMER
# O: Position sorted tab delimited file with info (coordinates, gc content, IDs) per chromatin feature.

BED=$1
#REF=$2
REF=/scratch/p275394/GRCh37.75.ref/Homo_sapiens.GRCh37.75.dna.toplevel.fa
################################
echo "## "$(date)" ##  $0 Start "
#####################################################################
echo Generating Feature information from annotation and reference genome
#####################################################################
#
awk 'BEGIN {OFS="\t"} {printf ("%s\t%s\t%s\t+\tID-%s\tID-%s\t1\tID-%s\tID-%s\tID-%s\n", $1, $2, $3, NR, NR, NR, NR, NR)}' ${BED} | \
                bedtools nuc -fi ${REF} -bed - | \
                        cut --complement -f11-13,16-18 | tail -n +2 | \
awk 'BEGIN {OFS="\t"} {printf ("%s\t%s\t%s\t%s\t%s\n", $0, 1, $2, $3, NR)}' | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
grep -v '^[GXYM]'> chromatinlist_sorted.txt
echo Generating side files
awk -F"\t" '{sum=($11+$12)/$13; print sum}' chromatinlist_sorted.txt > GCchromatin.txt
paste -d"\t" <(cut -f5 exonlist_sorted.txt) <(cut -f1-4 chromatinlist_sorted.txt) > chromatinlist_sorted.saf
sed -i '1s/^/GeneID\tChr\tStart\tEnd\tStrand\n/' chromatinlist_sorted.saf # run these two on the shell
#
bgzip -c chromatinlist_sorted.txt > chromatinlist_sorted.txt.gz
tabix -s 1 -b 2 -e 3 chromatinlist_sorted.txt.gz
################################
echo "## "$(date)" ##  $0 Done "
################################

