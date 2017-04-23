### Step 1: Calculate QC metrics on raw data

In this step, Fastqc, quality control (QC) metrics are calculated for the raw sequencing data. This is done using the tool FastQC. This tool will run a series of tests on the input file. The output is a text file containing the output data which is used to create a summary in the form of several HTML pages with graphs for each test. Both the text file and the HTML document provide a flag for each test: pass, warning or fail. This flag is based on criteria set by the makers of this tool. Warnings or even failures do not necessarily mean that there is a problem with the data, only that it is unusual compared to the used criteria. It is possible that the biological nature of the sample means that this particular bias is to be expected.

Toolname: FastQC

Scriptname: Fastqc

Input: FastQ files (${filePrefix}_${lane}_${barcode}.fq.gz)

Output: ${filePrefix}.fastqc.zip archive containing amongst others the HTML document and the text file

```
fastqc \
	fastq1.gz \
	fastq2.gz \
	-o outputDirectory
```
### Step 2: Read alignment against reference sequence

In this step, the Hisat Aligner is used to align the (mostly paired end) sequencing data to the reference genome. The output is a SAM file.

Scriptname: HisatAlignment

Input: raw sequence file in the form of a gzipped fastq file (${filePrefix}.fq.gz)
Output: SAM formatted file (${filePrefix}.sam)

Toolname: Hisat

```
hisat -x ${hisatIndex} \
	${input} \
	-p 8 \
	--rg-id ${externalSampleID} \
	--rg PL:illumina \
	--rg PU:${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	--rg LB:${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	--rg SM:${externalSampleID} \
	-S ${tmpAlignedSam} > ${intermediateDir}/${externalSampleID}_L${lane}.hisat.log 2>&1
	
```
### Step 3: Add Or Replace Readgroup

This step adds readgroup information to the reads in a bamfile. This additional meta data inproves the mark duplicate step by making it possible the identify different sequence runs for indiviual samples, but also various technical features that are associated with artifacts.

Toolname: Picard AddOrReplaceReadGroups

ToolVersion: 1.130-Java-1.7.0_80

Input: BAM files from step 2 ${filePrefix}_${barcode}.sorted.bam)

Output: merged BAM file ${filePrefix}_${barcode}.sorted.rg.bam)

java -Xmx6g -XX:ParallelGCThreads=8 -jar ${EBROOTPICARD}/${picardJar} AddOrReplaceReadGroups \
	INPUT=${sortedBam} \
	OUTPUT=${tmpAddOrReplaceGroupsBam} \
	SORT_ORDER=coordinate \
	RGID=${externalSampleID} \
	RGLB=${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	RGPL=ILLUMINA \
	RGPU=${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	RGSM=${externalSampleID} \
	RGDT=$(date --rfc-3339=date) \
	CREATE_INDEX=true \
	MAX_RECORDS_IN_RAM=4000000 \
 	TMP_DIR=${tempDir}

```
### Step 4: Merge BAM and build index

To improve the coverage of sequence alignments, a sample can be sequenced on multiple lanes and/or flowcells. If this is the case for the sample(s) being analyzed, this step merges all BAM files of one sample and indexes this new file. If there is just one BAM file for a sample, nothing happens.

Toolname: Picard mergeBam

ToolVersion: 1.130-Java-1.7.0_80

Input: BAM files from step 2 ${filePrefix}_${barcode}.sorted.bam)

Output: merged BAM file (${sample}. sorted .merged.bam)

java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} ${mergeSamFilesJar} \
	${INPUTS[@]} \
	SORT_ORDER=coordinate \
	CREATE_INDEX=true \
	USE_THREADING=true \
	TMP_DIR=${tempDir} \
	MAX_RECORDS_IN_RAM=6000000 \
	VALIDATION_STRINGENCY=LENIENT \
	OUTPUT=${tmpSampleMergedBam}

```
### Step 5: Mark duplicates + creating dedup metrics
In this step, the BAM file is examined to locate duplicate reads, using Picard MarkDuplicates. A mapped read is considered to be duplicate if the start and end base of two or more reads are located at the same chromosomal position in comparison to the reference genome. For paired-end data the start and end locations for both ends need to be the same to be called duplicate. One read pair of these duplicates is kept, the remaining ones are flagged as being duplicate.

Toolname: Picard MarkDuplicates 

Scriptname: MarkDuplicates

Input: Merged BAM file from generated in step 3 (${sample}.sorted.merged.bam)

Output: BAM file with duplicates flagged (${sample}.sorted.merged dedup.bam)
BAM index file (${sample}.dedup.bam.bai)
Dedup metrics file (${sample}.merged.dedup.metrics)

java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} MarkDuplicates \
	I=${sampleMergedBam} \
	O=${tmpSampleMergedDedupBam} \
	CREATE_INDEX=true \
	VALIDATION_STRINGENCY=LENIENT \
	M=${dupStatMetrics} AS=true


```
### Step 6: Calculate alignment QC metrics
In this step, QC metrics are calculated for the alignments created in the previous steps. This is done using several QC related tools:
•	${PICARD}/CollectRnaSeqMetrics
•	${GCC}/gentrap_graph_seqgc (GC bias plot) 
•	${SAMTOOLS}/flagstat 
•	${PICARD}/MarkDuplicates
•	${PICARD}/CollectInsertSizeMetrics (only paired end)

Toolname: several Picard or Samtools QC tools
ScriptVersions: Samtools/1.2-goolf-1.7.20, picard-tools/1.130-Java-1.7.0_80
Input: BAM file generated in step 4
Output: collectrnaseqmetrics, alignmentmetrics, gcbiasplots, insertsizemetrics, dedupmetrics, (text files and matching PDF files)

These metrics are later used to create tables and graphs (step 9). The Picard tools also output a PDF version of the data themselves, containing graphs.



### Step 7: HTSeq Count, Gene expression quantification
Before gene expression quantification SAMtools was used to sort the aligned reads by name. 
The gene level quantification was performed by HTSeq-0.6.1p1 using --mode=union --stranded=no|yes and, Ensembl version 75 was used as gene annotation database.

toolName: HTSeq Count 
toolVersion: HTSeq/0.6.1p1, Samtools/1.2-goolf-1.7.20
Input: BAM file
Output: Textfile with gene level quantification per sample.

samtools \
	view -h \
    ${sampleMergedBam}.nameSorted.bam | \
    $EBROOTHTSEQ/scripts/htseq-count \
    -m union \
    -s ${STRANDED} \
    - \
    ${annotationGtf} | \
    head -n -5 \
    > ${tmpSampleHTseqExpressionText}

```
### Step 8a: GATK: SplitAndTrim
In this step the data is pre-processed for variantcalling using GATK SplitNCigarReads,  which splits reads into exon segments (getting rid of Ns but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions. 

Toolname: GATK SplitNCigarReads
Scriptname: SplitAndTrim
Input: merged BAM files
Output: BAM file (${sample}.sorted.merged.dedup.splitAndTrim.bam)

java -Xmx9g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
  -T SplitNCigarReads \
  -R ${indexFile} \
  -I ${sampleMergedDedupBam} \
  -o ${tmpsplitAndTrimBam} \
  -rf ReassignOneMappingQuality \
  -RMQF 255 \
  -RMQT 60 \
  -U ALLOW_N_CIGAR_READS

```

### Step 8b: IndelRealignment
The local realignment process is designed to consume one or more BAM files and to locally realign reads such that the number of mismatching bases is minimized across all the reads.
Toolname GATK SplitAndTrim
Input: BAM file from step 8a
Output: BAM file (${sample}.sorted.merged.dedup.splitAndTrim. realigned.bam)

java -Xmx8g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-R ${indexFile} \
	-I ${splitAndTrimBam} \
	-o ${tmpIndelRealignedBam} \
	-targetIntervals ${indelRealignmentTargets} \
	-known ${oneKgPhase1IndelsVcf} \
	-known ${goldStandardVcf} \
	-U ALLOW_N_CIGAR_READS \
	--consensusDeterminationModel KNOWNS_ONLY \
	--LODThresholdForCleaning 0.4


### Step 8c: BQSR
In this step BQSR is performed. This is a data pre-processing step that detects systematic errors made by the sequencer when it estimates the quality score of each base call.
Toolname GATK BQSR
Input: BAM file from step 8b
Output: BAM file (${sample}.sorted.merged.dedup.splitAndTrim. realigned.bqsr.bam)

java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator\
	-R ${indexFile} \
	-I ${IndelRealignedBam} \
	-o ${bqsrBeforeGrp} \
	-knownSites ${dbsnpVcf} \
	-knownSites ${goldStandardVcf} \
	-knownSites ${oneKgPhase1IndelsVcf} \
	-nct 2

java -Xmx14g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R ${indexFile} \
	-I ${IndelRealignedBam} \
	-o ${tmpBqsrBam} \
	-BQSR ${bqsrBeforeGrp} \
	-nct 2
 
```

### Step 9a: HaplotypeCallerGvcf (VariantCalling)
The GATK HaplotypeCaller estimates the most likely genotypes and allele frequencies in a alignment using a Bayesian likelihood model for every position of the genome regardless of whether a variant was detected at that site or not. This information can later be used in the project based genotyping step.

Toolname: GATK HaplotypeCallerGvcf
Scriptname: HaplotypeCallerGvcf
Input: (${sample.sorted.merged.dedup.splitAndTrim.bam 
Output: gVCF file (${sample}.${batchBed}.variant.calls.g.vcf)

java -Xmx10g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R ${indexFile} \
	${inputs[@]} \
	--dbsnp ${dbsnpVcf}\
	-dontUseSoftClippedBases \
	-stand_call_conf 10.0 \
	-stand_emit_conf 20.0 \
	-o ${tmpGatkHaplotypeCallerGvcf} \
	-variant_index_type LINEAR \
	-variant_index_parameter 128000 \
	--emitRefConfidence GVCF

### Step 9b: Combine variants
When there 200 or more samples the gVCF files should be combined into batches of equal size. (NB: These batches are different then the ${batchBed}.)
The batches will be calculated and created in this step. If there are less then 200, this step will automatically be skipped.

Toolname: GATK CombineGVCFs
Scriptname: VariantGVCFCombine
Input: gVCF file (from step 9a)
Output: Multiple combined gVCF files ${project}.${batchBed}.variant.calls.combined.g.vcf{batch}

java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tmpTmpDataDir} -jar \
	${EBROOTGATK}/GenomeAnalysisTK.jar \
	-T CombineGVCFs \
	-R ${indexFile} \
	-L ${indexChrIntervalList} \
	-o ${tmpProjectBatchCombinedVariantCalls}.${b} \
	${ALLGVCFs[@]}

### Step 9c: Genotype variants

In this step there will be a joint analysis over all the samples in the project. This leads to a posterior probability of a variant allele at a site. SNPs and small Indels are written to a VCF file, along with information such as genotype quality, allele frequency, strand bias and read depth for that SNP/Indel.

Toolname: GATK GenotypeGVCFs
Scriptname: VariantGVCFGenotype
Input: gVCF files from step 9a or combined gVCF files from step 9b
Output: VCF file for all the samples in the project: ${project}.${batchBed}.variant.calls.genotyped.vcf

java -Xmx16g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
	-T GenotypeGVCFs \
	-R ${indexFile} \
 	--dbsnp ${dbsnpVcf}\
	-o ${tmpProjectBatchGenotypedVariantCalls} \
	${ALLGVCFs[@]} \
	-stand_call_conf 10.0 \
	-stand_emit_conf 20.0

### Step 10: MakeExpressionTable
In this step, gene level quantification files per sample, created in step 6 are merged into one table, using a inhouse developt script ProcessReadCounts.

Scriptname: MakeExpressionTable
Input: textfile with gene level quantification per sample.
Output: gene level quantification table with all samples in the project.

java -Xmx1g -XX:ParallelGCThreads=1 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTNGSMINUTILS}/${processReadCountsJar} \
	--mode makeExpressionTable \
	--fileList ${intermediateDir}/fileList.txt \
	--annot ${geneAnnotationTxt} \
	--out ${tmpProjectHTseqExpressionTable}

### Step 11: Generate quality control report
This step is to collect the statistics and metrics from step 3. Tables and graphs merged into a HTML and PDF Reports using KnitR. QC reports are then written to a quality control (QC) directory. 

Scriptname: QC_report
Input: QC statistics and metrics.
Output: QC report (.QCReport.pdf)


### Step 12: Kallisto
In this step kallisto is for quantifying abundances of transcripts from RNA-Seq data, or more generally of target sequences using high-throughput sequencing reads. 

Scriptname: Kallisto
Input: raw sequence file in the form of a gzipped fastq file (.fq.gz)
Output: results of the main quantification, i.e. the abundance estimate using Kallisto on the data is in the abundance.txt

kallisto quant \
	-i ${kallistoIndex} \
	-o ${tmpIntermediateDir}/${uniqueID} \
	${peEnd1BarcodeFqGz} ${peEnd2BarcodeFqGz}

### Step 13: Prepare data to ship to the customer
In this last step the final results of the inhouse sequence analysis pipeline are gathered and prepared to be shipped to the customer. The pipeline tools and scripts write intermediate results to a temporary directory. From these, a selection is copied to a results directory. This directory has five subdirectories:

-	alignment: merged BAM file with index
-	expression: textfiles with gene level quantification per sample, and per project
-	fastqc: FastQC output 
-	images: QC images
-	variants: VCF file with calling SNPs and indels.
-	rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)


Additionally, the results directory contains the final QC report, a README.txt with used pipeline description and toolversions, and the samplesheet which was the basis for this analysis and a zipped archive with the data that will be shipped to the client. The archive is accompanied by an md5 sum.
