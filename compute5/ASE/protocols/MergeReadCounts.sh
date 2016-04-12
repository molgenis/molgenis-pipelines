#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string imputedVcf
#string bam

#string chromosome

echo "## "$(date)" Start $0"

getFile ${imputedVcf}
getFile ${bam}


${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}




let COUNTER=COUNTER-1
paste -d "\t" part{0..$COUNTER} | paste -d "\t" $EXONLIST - > CountTable.txt #; rm part*
###########################################################################
### GENERATE per exon rasuql files from CountTable
echo Generating files per exon
let OFFSET=COUNTER+3
awk '{ prc = ($9 + $10) / $14 ; print prc }' CountTable.txt > GCce.txt # GC content
cut -f4,15-$OFFSET CountTable.txt > Ye.txt # Will have same IDs for all exons but can be distinguished by nums column 
cut -f4 CountTable.txt > a.txt
cut -f1,2,3 CountTable.txt > b.txt
cut -f2,3 CountTable.txt > c.txt
awk '{print NR}' CountTable.txt > nums.txt
paste -d "\t" a.txt b.txt c.txt nums.txt > MainE.txt #; rm a.txt b.txt c.txt nums.txt
###########################################################################
### GENERATE per gene rasuql files from CountTable
echo Generating files per gene
sort -k4,4d -k1,1d -k2,2n -t $'\t' CountTable.txt > CountTable_sorted_transcript.txt # Temp sort by ID name to collapse
######Bedtools can't handle one simultanous groupby commad  so split files first to avoid crashing it DIRTY FIX
cut -f1,2,3,4 CountTable_sorted_transcript.txt > Positions.txt
cut -f1,2,4,9,10,14 CountTable_sorted_transcript.txt > Content.txt
cut -f1,2,5,15-38 CountTable_sorted_transcript.txt > Counts.txt
###### Collapsing splits of the file
bedtools groupby -i Positions.txt -g 4 -c 1,2,3,2,3 -o first,first,last,collapse,collapse > collapsed_Positions.txt #; rm Positions.txt
bedtools groupby -i Content.txt -g 3 -c 1,2,4,5,6 -o first,first,sum,sum,sum > collapsed_Content.txt #; rm Content.txt
#
oper='first,first,'
oper+=`printf 'sum,%.0s' {0..22}` #Arbitrary
oper+='sum'
bedtools groupby -i Counts.txt -g 3 -c 1,2,4-27 -o $oper > collapsed_Counts.txt #; rm Counts.txt #Arbitrary
#
######
sort -k2,2d -k3,3n collapsed_Counts.txt | cut -f1,4-27 - > Yt.txt #Arbitrary
cat Yt.txt | awk '{ for(i=2; i<=NF;i++) j+=$i; print j/24; j=0 }' > Ct.txt #Arbitrary # Get mean read count for each feature
sort -k2,2d -k3,3n collapsed_Content.txt | awk '{ prc = ($4 + $5) / $6 ; print prc }' - > GCct.txt 
#
sort -k2,2d -k3,3n collapsed_Positions.txt > sorted_Positionst.txt
awk '{print NR}' sorted_Positionst.txt | paste -d "\t" sorted_Positionst.txt - > MainT.txt #; rm collapsed_* sorted_Positionst.txt
#
######
echo finished
