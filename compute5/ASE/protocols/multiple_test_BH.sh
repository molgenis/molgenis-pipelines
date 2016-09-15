#!/bin/sh
# This script takes the output from RASQUAL and outputs the significant SNPs according to the BH procedure
# Input: RASQUAL output, FDR Output: Sorted Rasqual output sorted by chisq value with only the significant results at $FDR
module load R
FDR=$2
echo Getting lead QTLs
grep -v SKIPPED  $1 | grep -v LAST |  awk -F "\t" '$17 > 0 {print $0}' | \
sort -t$'\t' -k11,11nr | awk '!seen[$5]++' > "$1".sorted
echo Total
echo $(wc -l "$1".sorted)
Total=$(cat "$1".sorted| wc -l)
#echo passed the test
Rscript BenjaminiHcalculator2.R "$1".sorted 1 $Total $FDR "$1.lead2"
# run the BH procedure : outputs BHvalues.tmp
# keep only those before the cutoff
#rm leadQTLs.tmp
#cleanup
echo Done

