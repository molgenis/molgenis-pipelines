#
# =====================================================
# $Id: CopyToResultsDir.ftl 12202 2012-06-15 09:10:27Z freerkvandijk $
# $URL: http://www.molgenis.org/svn/molgenis_apps/trunk/modules/compute/protocols/CopyToResultsDir.ftl $
# $LastChangedDate: 2012-06-15 11:10:27 +0200 (Fri, 15 Jun 2012) $
# $LastChangedRevision: 12202 $
# $LastChangedBy: freerkvandijk $
# =====================================================
#

#MOLGENIS walltime=23:59:00
#FOREACH project


alloutputsexist "${projectResultsDir}/${project}.zip"

# Change permissions

umask 0007


# Make result directories
mkdir -p ${projectResultsDir}/rawdata
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/coverage
mkdir -p ${projectResultsDir}/snps
mkdir -p ${projectResultsDir}/structural_variants
mkdir -p ${projectResultsDir}/qc/statistics


# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}


# Create symlinks for all fastq and md5 files to the project results directory

cp -rs ${projectrawdatadir} ${projectResultsDir}/rawdata


# Copy fastQC output to results directory
cp ${intermediatedir}/*_fastqc.zip ${projectResultsDir}/qc


# Copy dedup metrics to results directory
cp ${intermediatedir}/*.dedup.metrics ${projectResultsDir}/qc/statistics


# Create md5 sum and copy merged BAM plus index plus md5 sum to results directory
<#if 0 &lt; mergedbam?size>
	<#list 0..(mergedbam?size-1) as index>
		md5sum ${mergedbam[index]} > ${mergedbam[index]}.md5
		md5sum ${mergedbamindex[index]} > ${mergedbamindex[index]}.md5
		cp ${mergedbam[index]}* ${projectResultsDir}/alignment
	</#list>
</#if>

# Copy alignment stats (lane and sample) to results directory

cp ${intermediatedir}/*.alignmentmetrics ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.gcbiasmetrics ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.insertsizemetrics ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.meanqualitybycycle ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.qualityscoredistribution ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.hsmetrics ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.bamindexstats ${projectResultsDir}/qc/statistics
cp ${intermediatedir}/*.pdf ${projectResultsDir}/qc/statistics


# Copy coverage stats (for future reference) to results directory

cp ${intermediatedir}/*.coverage* ${projectResultsDir}/coverage


# Copy final SNP and SV vcf and vcf.table to results directory

<#list sample as s>

	cp ${s}.snps.final.vcf ${projectResultsDir}/snps/
	cp ${s}.snps.final.vcf.table ${projectResultsDir}/snps/
	cp ${s}.indels.final.vcf ${projectResultsDir}/structural_variants/
	cp ${s}.indels.final.vcf.table ${projectResultsDir}/structural_variants/


	# Copy genotype array vcf to results directory

	if [ -f "${s}.genotypeArray.updated.header.vcf" ]
	then
		cp ${s}.genotypeArray.updated.header.vcf ${projectResultsDir}/qc
	fi

	cp ${s}.concordance.ngsVSarray.txt ${projectResultsDir}/qc

</#list>

# Copy QC report to results directory

cp ${qcdir}/${project}_QCReport.pdf ${projectResultsDir}


# save latex README template in file
echo "<#include "CopyToResultsDirREADMEtemplate.tex"/>" > ${projectResultsDir}/README.txt

pdflatex -output-directory=${projectResultsDir} ${projectResultsDir}/README.txt


# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -r ${projectResultsDir}/${project}.zip snps
zip -gr ${projectResultsDir}/${project}.zip qc
zip -gr ${projectResultsDir}/${project}.zip structural_variants
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -g ${projectResultsDir}/${project}.zip README.pdf
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf

# Create md5sum for zip file

cd ${projectResultsDir}

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5