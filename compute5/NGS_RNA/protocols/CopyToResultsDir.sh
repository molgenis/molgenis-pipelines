#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectQcDir
#string projectJobsDir
#string projectHTseqExpressionTable
#string annotationGtf
#string anacondaVersion
#string indexFileID
#string seqType
#string jdkVersion
#string fastqcVersion
#string samtoolsVersion
#string RVersion
#string wkhtmltopdfVersion
#string picardVersion
#string hisatVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string ghostscriptVersion
#string ensembleReleaseVersion
#string groupname
#string tmpName

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/fastqc
mkdir -p ${projectResultsDir}/expression
mkdir -p ${projectResultsDir}/expression/perSampleExpression
mkdir -p ${projectResultsDir}/expression/expressionTable
mkdir -p ${projectResultsDir}/images
mkdir -p ${projectResultsDir}/variants
mkdir -p ${projectResultsDir}/qcmetrics

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}

# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/fastqc

# Copy BAM plus index plus md5 sum to results directory

usedWorkflow=$(basename ${workflow})

if [ "${usedWorkflow}" == "workflow_lexogen.csv" ]
then
	cp ${intermediateDir}/*.unique_mapping_reads.sorted.merged.dedup.bam ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.unique_mapping_reads.sorted.merged.dedup.bam.md5 ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.unique_mapping_reads.sorted.merged.dedup.bai ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.unique_mapping_reads.sorted.merged.dedup.bai.md5 ${projectResultsDir}/alignment
else
	cp ${intermediateDir}/*.sorted.merged.dedup.splitAndTrim.bam ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.splitAndTrim.bam.md5 ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.splitAndTrim.bai ${projectResultsDir}/alignment
        cp ${intermediateDir}/*.sorted.merged.dedup.splitAndTrim.bai.md5 ${projectResultsDir}/alignment
fi

# copy qc metrics to qcmetrics folder

	cp ${intermediateDir}/*.hisat.log ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_by_cycle_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_by_cycle.pdf ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_distribution.pdf ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.quality_distribution_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.base_distribution_by_cycle.pdf ${projectResultsDir}/qcmetrics 
	cp ${intermediateDir}/*.base_distribution_by_cycle_metrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.alignment_summary_metrics ${projectResultsDir}/qcmetrics
        cp ${intermediateDir}/*.flagstat ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.mdupmetrics ${projectResultsDir}/qcmetrics
	cp ${intermediateDir}/*.collectrnaseqmetrics ${projectResultsDir}/qcmetrics

	if [ "${seqType}" == "PE" ]
        then
		cp ${intermediateDir}/*.insert_size_metrics ${projectResultsDir}/qcmetrics
	else
		echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi

# copy GeneCounts to results directory

	cp ${intermediateDir}/*.htseq.txt ${projectResultsDir}/expression/perSampleExpression
	cp ${projectHTseqExpressionTable} ${projectResultsDir}/expression/expressionTable
	cp ${annotationGtf} ${projectResultsDir}/expression/

# Copy QC images and report to results directory

	cp ${intermediateDir}/*.collectrnaseqmetrics.png ${projectResultsDir}/images
	cp ${intermediateDir}/*.GC.png ${projectResultsDir}/images
	cp ${projectQcDir}/${project}_QCReport.html ${projectResultsDir}
	cp ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}

# Copy variants vcfs to results directory

	usedWorkflow=$(basename ${workflow})
	if [ "${usedWorkflow}" == "workflow_lexogen.csv" ]
        then
		echo "Variant vcfs are not existing, skipped"
	else
		cp ${intermediateDir}/${project}.variant.calls.genotyped.*.vcf* ${projectResultsDir}/variants
	fi

#only available with PE
	if [ "${seqType}" == "PE" ]
	then
		cp ${intermediateDir}/*.insertsizemetrics.png ${projectResultsDir}/images
		cp ${intermediateDir}/*.insert_size_histogram.pdf ${projectResultsDir}/images
	else
                echo "Skip insertSizeMetrics. seqType is: ${seqType}"
	fi


# write README.txt file

cat > ${projectResultsDir}/README.txt <<'endmsg'

Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands

Description of the different steps used in the RNA analysis pipeline

RNA Isolation, Sample Preparation and sequencing
Initial quality check of and RNA quantification of the samples was performed by capillary 
electrophoresis using the LabChip GX (Perkin Elmer). Non-degraded RNA-samples were 
selected for subsequent sequencing analysis. 
Sequence libraries were generated using the TruSeq RNA sample preparation kits (Illumina) 
using the Sciclone NGS Liquid Handler (Perkin Elmer). In case of contamination of adapter-
duplexes an extra purification of the libraries was performed with the automated agarose 
gel separation system Labchip XT (PerkinElmer). The obtained cDNA fragment libraries were 
sequenced on an Illumina HiSeq2500 using default parameters (single read 1x50bp or Paired 
End 2 x 100 bp) in pools of multiple samples.

Gene expression quantification
The trimmed fastQ files where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion} 
reference genome using ${hisatVersion} [1] with default settings. Before gene quantification 
${samtoolsVersion} [2] was used to sort the aligned reads. 
The gene level quantification was performed by HTSeq-count ${htseqVersion} [3] using --mode=union, 
Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included
in folder expression/. 

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using 
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using 
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and ${samtoolsVersion} flagstat.

GATK variant calling
Variant calling was done using GATK. First, we use a GATK tool called SplitNCigarReads
developed specially for RNAseq, which splits reads into exon segments (getting rid of Ns
but maintaining grouping information) and hard-clip any sequences overhanging into the intronic regions.
The variant calling it self was done using HaplotypeCaller in GVCF mode. All  samples are 
then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs 
on all of them together to create a set of raw SNP and indel calls per chomosome. [6]



Results archive
The zipped archive contains the following data and subfolders:

- alignment: merged BAM file with index, md5sums and alignment statistics (.Log.final.out)
- expression: textfiles with gene level quantification per sample and per project. 
- fastqc: FastQC output
- images: QC images
- qcmetrics: Multiple qcMetrics generated with Picard-tools or SAMTools Flagstat.
- variants: Variants calls using GATK. (optional)
- rawdata: raw sequence file in the form of a gzipped fastq file (.fq.gz)

The root of the results directory contains the final QC report, README.txt and the samplesheet which 
form the basis for this analysis. 

Used toolversions:

${jdkVersion}
${fastqcVersion}
${samtoolsVersion}
${RVersion}
${wkhtmltopdfVersion}
${picardVersion}
${htseqVersion}
${pythonVersion}
${gatkVersion}
${ghostscriptVersion}
${hisatVersion}

1. Daehwan Kim, Ben Langmead & Steven L Salzberg: HISAT: a fast spliced aligner with low
memory requirements. Nature Methods 12, 357–360 (2015)
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
Bioinforma 2009, 25 (16):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online]. 
Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}
5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}
6. The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data. 
McKenna A et al.2010 GENOME RESEARCH 20:1297-303, Version: ${gatkVersion}

endmsg

# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip fastqc
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -gr ${projectResultsDir}/${project}.zip qcmetrics
zip -gr ${projectResultsDir}/${project}.zip expression
zip -gr ${projectResultsDir}/${project}.zip variants
zip -gr ${projectResultsDir}/${project}.zip images
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf
zip -g ${projectResultsDir}/${project}.zip README.txt

# Create md5sum for zip file

cd ${projectResultsDir}
md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
cd ${projectJobsDir}

# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}
chmod -R g+rwX ${intermediateDir}
