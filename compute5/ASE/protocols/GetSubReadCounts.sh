#MOLGENIS walltime=70:59:00 mem=10gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string WORKDIR
#string projectDir
#string bam
#string transcriptSAF
#string exonSAF
#string geneSAF
#string readCountDir
#string readCountFileGene
#string readCountFileExon
#string readCountFileTranscript
#string subreadVersion
#string sampleName
#string stranded
#string CHR

echo "## "$(date)" Start $0"

getFile ${bam}

mkdir -p ${readCountDir}

#Load Subread module
${stage} Subread/${subreadVersion}
${checkStage}


#O: Y.txt Gcc.txt file generated for RASQUAL Main.txt file with gene data C.txt counts per gene
#W: Make sure the formats are the same for exonlist and BAMS chr1/1..chrX/X

#Get featureCounts and group per gene

echo "Retrieving gene counts"

featureCounts \
-F SAF \
-O \
-s ${stranded} \
-p \
-B \
-a ${geneSAF} \
-o $TMPDIR/${sampleName}.chr${CHR}.txt \
${bam}

tail -n +3 $TMPDIR/${sampleName}.chr${CHR}.txt | \
LC_ALL=C \
sort -t$'\t' -k1,1 | \
cut -f7 > ${readCountFileGene}


featureCounts -F SAF -O -s ${stranded} -p -B -a ${exonSAF} -o $TMPDIR/${sampleName}.txt ${bam}
tail -n +3 $TMPDIR/${sampleName}.txt | LC_ALL=C sort -t$'\t' -k1,1 | cut -f7 > ${readCountFileGene}

echo "Done retrieving gene counts"



## Per Exon

echo "Retrieving exon counts"

featureCounts \
-F SAF \
-O \
-f \
-s ${stranded} \
-p \
-B \
-a ${exonSAF} \
-o $TMPDIR/${sampleName}.chr${CHR}.txt \
${bam}

tail -n +3 $TMPDIR/${sampleName}.chr${CHR}.txt | \
cut -f7 > ${readCountFileExon}

echo "Done retrieving exon counts"



## Per transcript

echo "Retrieving transcript counts"

featureCounts \
-F SAF \
-O \
-f \
-s ${stranded} \
-p \
-B \
-a ${transcriptSAF} \
-o $TMPDIR/${sampleName}.chr${CHR}.txt \
${bam}

tail -n +3 $TMPDIR/${sampleName}.chr${CHR}.txt | \
cut -f7 > ${readCountFileTranscript}

echo "Done retrieving transcript counts"

echo "## "$(date)" ##  $0 Done "

