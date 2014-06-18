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


# Make result directories
mkdir -p ${projectResultsDir}/alignment
mkdir -p ${projectResultsDir}/fastqc
mkdir -p ${projectResultsDir}/expression
mkdir -p ${projectResultsDir}/expression/perSampleExpression
mkdir -p ${projectResultsDir}/expression/expressionTable

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



# Copy QC report to results directory

#cp ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}



# Create zip file for all "small text" files

cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip fastqc
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
zip -gr ${projectResultsDir}/${project}.zip alignment
zip -gr ${projectResultsDir}/${project}.zip expression

#zip -gr ${projectResultsDir}/fastqc
#zip -g ${projectResultsDir}/${project}.zip README.pdf
#zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf

# Create md5sum for zip file

cd ${projectResultsDir}

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
