#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectrawdatadir
#string projectQcDir
#string projectJobsDir
#string expressionTable

alloutputsexist "${projectResultsDir}/${project}.zip"

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/fastqc
mkdir -p ${projectResultsDir}/expression
mkdir -p ${projectResultsDir}/expression/perSampleExpression
mkdir -p ${projectResultsDir}/expression/expressionTable
mkdir -p ${projectResultsDir}/images

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}


# Create symlinks for all fastq and md5 files to the project results directory

	cp -rs ${projectrawdatadir} ${projectResultsDir}/rawdata


# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/fastqc



# Copy BAM plus index plus md5 sum to results directory

	cp ${intermediateDir}/*.Aligned.out.sorted.bam ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Aligned.out.sorted.bam.md5 ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Aligned.out.sorted.bai ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.SJ.out.tab.gz ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Log.final.out ${projectResultsDir}/alignment
	cp ${intermediateDir}/*.Log.out ${projectResultsDir}/alignment

# copy GeneCounts to results directory

	cp ${intermediateDir}/*.htseq.txt ${projectResultsDir}/expression/perSampleExpression
	cp ${expressionTable} ${projectResultsDir}/expression/expressionTable
	
# Copy QC images and report to results directory

	cp ${intermediateDir}/*.collectrnaseqmetrics.png ${projectResultsDir}/images
	cp ${intermediateDir}/*.GC.png ${projectResultsDir}/images
	cp ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}

#only available with PE
	if [ -f "${intermediateDir}/*.insertsizemetrics.pdf" ]
	then
		cp ${intermediateDir}/*.insertsizemetrics.pdf ${projectResultsDir}/images
	fi

# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip fastqc
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -gr ${projectResultsDir}/${project}.zip alignment
zip -gr ${projectResultsDir}/${project}.zip expression
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf

# Create md5sum for zip file

cd ${projectResultsDir}
md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
