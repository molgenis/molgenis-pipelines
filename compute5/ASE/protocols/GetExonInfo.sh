#!bin/bash

#SBATCH --job-name=MakeAnnotations.sh
#SBATCH --time=24:00:00
#SBATCH --partition=himem
#SBATCH --mem=30G
#SBATCH --output=O.txt

module load BEDTools

# Generates Exon Information Files
# I: $1 Reference sequence in FASTA fromat .fa $2 Genome anotation in Genome Transfer File fromat .gtf FROM SAME BUILD
# O: Position sorted tab delimited file with info (coordinates, gc content, IDs) per transcript, per exona nd per forced gene.

GTF=$1
REF=$2

################################
echo "## "$(date)" ##  $0 Start "
#####################################################################
echo Generating Exon information from annotation and reference genome
#####################################################################
export LC_ALL=C
#
awk -F "\t" '$3 == "exon" { print $0 }' ${GTF} | \
	tr ' ' \\t | sed 's/[;"]//g' | \
		cut -f1,4,5,10,12,14,16,22,26 | \
			sort -t $'\t' -k1,1d -k2,2n | \
				bedtools nuc -fi ${REF} -bed - | \
					cut --complement -f10-12,15-17 | tail -n +2 | \
awk 'BEGIN {FS=OFS="\t"} {printf ("%s\t%s\t%s\t%s\t%s\n", $0, 1, $2, $3, NR)}' > exonlist_sorted.txt
awk -F"\t" '{sum=($10+$11)/$12; print sum}' exonlist_sorted.txt > GCexon.txt
bgzip -c exonlist_sorted.txt > exonlist_sorted.txt.gz
tabix -s 1 -b 2 -e 3 exonlist_sorted.txt.gz
##################################################
echo Generating feature information per gene
##################################################
#
sort -t $'\t' -k5,5d -k1,1d -k2,2n exonlist_sorted.txt | \
		bedtools groupby \
       		-g 5 \
		-c 1-13,2,3 \
       		-o first,first,last,first,first,first,first,first,first,sum,sum,sum,sum,collapse,collapse | \
			sort -t $'\t' -k2,2d -k3,3n | cut --complement -f1 | \
awk -F "\t" 'BEGIN {OFS="\t"} { $6 = "."; $9 = "."; $5 = $4; $8 = $7; print}' | \
	awk 'BEGIN {FS=OFS="\t"} {printf ("%s\t%s\n", $0, NR)}' > transcriptlist_sorted.txt
awk -F"\t" '{sum=($10+$11)/$12; print sum}' transcriptlist_sorted.txt > GCTranscript.txt
bgzip -c transcriptlist_sorted.txt > transcriptlist_sorted.txt.gz
tabix -s 1 -b 2 -e 3 transcriptlist_sorted.txt.gz
#############################################################
echo Generating annotation of forced consensus gene
#############################################################
# Escape if the file is merged already
if [ ${GTF: -4} == ".Gtf" ]; then exit; done
rm metaAnnotation.Gtf
#
Merge_print () {
	name=$1[@]
	stack=("${!name}")
	printf '%s\n' "${stack[@]}" | \
		bedtools merge \
		-c 4,5 \
		-o distinct,distinct \
		-i - | \
	awk 'BEGIN {FS=OFS="\t"} {printf ("%s\tmetaGene\texon\t%s\t%s\t.\t.\t.\tgene_id %s; transcript_id %s; exon_number %s; gene_name %s; gene_source .; gene_biotype .; transcript_name %s; transcript_source .; exon_id .;\n", $1, $2, $3, $4, $4, NR, $5, $5)}' >> metaAnnotation.Gtf
	####
}
Flag=0
while read line
do
	current=$(echo "$line" | cut -f4)
	if (( Flag == 0)); then old=$current; Flag=1; fi
	if [ $old != $current ]; then
		Merge_print stack
		stack=()
		old=$current
	fi    
	stack+=("$line")
done < <(cut -f1-4,7 exonlist_sorted.txt | sort -t $'\t' -k4,4d -k1,1d -k2,2n)
Merge_print stack
################################
echo "## "$(date)" ##  $0 Done "
################################
