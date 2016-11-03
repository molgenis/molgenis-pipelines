#!bin/bash

#SBATCH --job-name=MakeAnnotations.sh
#SBATCH --time=24:00:00
#SBATCH --partition=himem
#SBATCH --mem=30G
#SBATCH --output=O.txt

module load BEDTools/2.23.0-goolf-1.7.20
module load tabix/0.2.6-goolf-1.7.20

# Generates Exon Information Files
# O: Position sorted tab delimited file with info (coordinates, gc content, IDs) per transcript, per exona nd per forced gene.
# This scripts contains pipe redirections <() that sometimes dont work with sbatch: run the SAF generator in the shell

#Iterate over all 22 chromosomes
for CHR in {1..22}
do

GTF="/apps/data/UMCG/Ensembl.GRCh37.75-Exon_And_GeneList/Homo_sapiens.GRCh37.75.chr$CHR.gtf"
REF="/apps/data/ftp.broadinstitute.org/bundle/2.8/b37/human_g1k_v37.fasta"

	echo "## "$(date)" ##  $0 Start "
	
	
	echo "Generating Exon information from annotation and reference genome for chromosome $CHR"
	
	
	#Generate exonlist information
	awk -F "\t" '{if ($3=="exon") print $0 }' ${GTF} | \
	tr ' ' \\t | sed 's/[;"]//g' | \
	cut -f1,4,5,7,10,12,14,16,22,26 | \
	LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
	bedtools nuc -fi ${REF} -bed - | \
	cut --complement -f11-13,16-18 | tail -n +2 | \
	awk 'BEGIN {FS=OFS="\t"} {printf ("%s\t%s\t%s\t%s\t%s\n", $0, 1, $2, $3, NR)}' | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n > exonlist_sorted.chr$CHR.txt
	
	# paste -d"\t" <(cut -f5 exonlist_sorted.txt) <(cut -f1-4 exonlist_sorted.txt) > exonlist_sorted.saf
	# sed -i '1s/^/GeneID\tChr\tStart\tEnd\tStrand\n/' exonlist_sorted.saf # run these two on the shell
	
	awk -F"\t" '{sum=($11+$12)/$13; print sum}' exonlist_sorted.chr$CHR.txt > GCexon.chr$CHR.txt
	bgzip -c exonlist_sorted.chr$CHR.txt > exonlist_sorted.chr$CHR.txt.gz
	tabix -s 1 -b 2 -e 3 exonlist_sorted.chr$CHR.txt.gz
	
	
	
	#Generate files per transcript
	echo "Generating feature information per gene"
	
	sort -t $'\t' -k6,6d -k1,1d -k2,2n exonlist_sorted.chr$CHR.txt | \
	bedtools groupby \
	-g 6 \
	-c 1-14,2,3 \
	-o first,first,last,first,first,first,first,first,first,first,sum,sum,sum,sum,collapse,collapse | \
	cut --complement -f1 | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
	awk -F "\t" 'BEGIN {OFS="\t"} { $7 = "."; $10 = "."; $6 = $5; $9 = $8; print}' | \
	LC_ALL=C sort -t $'\t' -k5,5 | awk 'BEGIN {FS=OFS="\t"} {printf ("%s\t%s\n", $0, NR)}' | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n > transcriptlist_sorted.chr$CHR.txt
	
	awk -F"\t" '{sum=($11+$12)/$13; print sum}' transcriptlist_sorted.chr$CHR.txt > GCTranscript.chr$CHR.txt
	bgzip -c transcriptlist_sorted.chr$CHR.txt > transcriptlist_sorted.chr$CHR.txt.gz
	tabix -s 1 -b 2 -e 3 transcriptlist_sorted.chr$CHR.txt.gz
	
	
	
	#Generate files per gene
	echo "Generating annotation of forced consensus gene"
	
	awk -F "\t" '{if ($3=="gene") print $0 }' ${GTF} | \
	tr ' ' \\t | sed 's/[;"]//g' | \
	cut -f1,4,5,7,10,12,14,16,22,26 | \
	LC_ALL=C sort -t $'\t' -k1,1 -k2,2n | \
	bedtools nuc -fi ${REF} -bed - | \
	cut --complement -f11-13,16-18 | tail -n +2 | \
	awk 'BEGIN {FS=OFS="\t"} {printf ("%s\t%s\t%s\t%s\t%s\n", $0, 1, $2, $3, NR)}' | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n > genelist_sorted.chr$CHR.txt
	
	awk -F"\t" '{print $10}' genelist_sorted.chr$CHR.txt > GCgene.chr$CHR.txt
	bgzip -c genelist_sorted.chr1.txt > genelist_sorted.chr$CHR.txt.gz
	tabix -s 1 -b 2 -e 3 genelist_sorted.chr$CHR.txt.gz
	
	
	
	# Escape if the file is merged already
	if [ ${GTF: -4} == ".Gtf" ]; 
	then 
		exit; 
	fi 
	
	cut -f1-5,8 exonlist_sorted.chr$CHR.txt | LC_ALL=C sort -t $'\t' -k5,5d -k1,1d -k2,2n | \
	awk 'BEGIN{OFS=FS="\t"}{temp=$1; $1=$5; $5=temp; print $0}' | \
	bedtools merge -i - -c 4,5,6 -o first,first,first | \
	awk 'BEGIN {FS=OFS="\t"} {printf ("%s\tmetaGene\texon\t%s\t%s\t.\t%s\t.\tgene_id %s; transcript_id %s; exon_number %s; gene_name %s; gene_source .; gene_biotype .; transcript_name %s; transcript_source .; exon_id .;\n", $5, $2, $3, $4, $1, $1, NR, $6, $6)}' > metaAnnotation.chr$CHR.Gtf

done

echo "## "$(date)" ##  $0 Done "


