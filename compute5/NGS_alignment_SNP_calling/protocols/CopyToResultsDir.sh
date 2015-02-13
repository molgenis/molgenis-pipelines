#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectQcDir
#string projectLogsDir
#string projectRawTmpDataDir
#string projectQcDir
#string projectJobsDir
#list externalSampleID
#list chr
#string pindelOutputVcf


# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/coverage
mkdir -p ${projectResultsDir}/qc
mkdir -p ${projectResultsDir}/qc/statistics
mkdir -p ${projectResultsDir}/rawdata
mkdir -p ${projectResultsDir}/snps
mkdir -p ${projectResultsDir}/structural_variants

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}


# Create symlinks for all fastq and md5 files to the project results directory

	cp -rs ${projectRawTmpDataDir} ${projectResultsDir}/rawdata
	
# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/qc

# Copy BAM plus index plus md5 sum to results directory

for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam ${projectResultsDir}/alignment
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bai ${projectResultsDir}/alignment
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.md5 ${projectResultsDir}/alignment
done

# Copy alignment stats (lane and sample) to results directory

for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.alignment_summary_metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.gc_bias_metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.quality_by_cycle_metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.quality_distribution_metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.hs_metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.bam_index_stats ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}.merged.dedup.metrics ${projectResultsDir}/qc/statistics
	cp ${intermediateDir}/${sample}*.pdf ${projectResultsDir}/qc/statistics
done
	
#only available with PE

        if [ -f "${intermediateDir}/*.insert_size_metrics" ]
        then
		for sample in "${externalSampleID[@]}"
		do
			cp ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam.insert_size_metrics ${projectResultsDir}/qc/statistics
		done
        fi


# Copy SNP and SV vcf and tables to results directory

	cp ${intermediateDir}/${project}.snpEff.annotated.snps.dbnsfp.final.vcf ${projectResultsDir}/snps

for sample in "${externalSampleID[@]}"
do	
	cp ${intermediateDir}/${sample}.snpEff.annotated.snps.dbnsfp.final.vcf ${projectResultsDir}/snps
	
	cp ${intermediateDir}/${sample}.snpEff.annotated.indels.final.vcf ${projectResultsDir}/structural_variants
	cp ${intermediateDir}/${sample}.snpEff.annotated.indels.final.vcf.table ${projectResultsDir}/structural_variants
	cp ${intermediateDir}/${sample}.output.pindel.merged.vcf ${projectResultsDir}/structural_variants
done

# print README.txt files

#
## to do
#


# Copy QC report to results directory

cp ${projectQcDir}/${project}_QCReport.md ${projectResultsDir}
cp -r ${projectQcDir}/images ${projectResultsDir}


# Create zip file for all "small text" files

cd ${projectResultsDir}


zip -gr ${projectResultsDir}/${project}.zip snps
zip -gr ${projectResultsDir}/${project}.zip qc
zip -gr ${projectResultsDir}/${project}.zip images
zip -gr ${projectResultsDir}/${project}.zip structural_variants
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
#zip -g ${projectResultsDir}/${project}.zip README.pdf
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.md

# Create md5sum for zip file

cd ${projectResultsDir}

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5

# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}
