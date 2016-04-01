#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping

#string project
#string projectResultsDir
#string logsDir
#string projectPrefix
#string intermediateDir
#string projectQcDir
#string projectLogsDir
#string projectRawTmpDataDir
#string projectQcDir
#string projectJobsDir
#list externalSampleID
#list batchID
#list seqType

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment/
mkdir -p ${projectResultsDir}/coverage/
mkdir -p ${projectResultsDir}/qc/statistics/
mkdir -p ${projectResultsDir}/variants/
#mkdir -p ${projectResultsDir}/Pindel/

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}
echo "Copied error, out and finished logs to project jobs directory (1/11)"

# Copy project csv file to project results directory
cp ${projectJobsDir}/${project}.csv ${projectResultsDir}
echo "Copied project csv file to project results directory (2/11)"

# Copy fastQC output to results directory
cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/qc/
echo "Copied fastQC output to results directory (3/11)"

#copy realigned bams
for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.bam ${projectResultsDir}/alignment/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.bai ${projectResultsDir}/alignment/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.md5 ${projectResultsDir}/alignment/
done
echo "Copied realigned bams (4/11)"

# Copy alignment stats (lane and sample) to results directory

for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.bam.alignment_summary_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.gc_bias_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.quality_by_cycle_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.quality_distribution_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.hs_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.bam.bam_index_stats ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}*.pdf ${projectResultsDir}/qc/statistics/
	echo "Copied alignment stats (lane and sample) to results directory (5/11)"
done

#copy insert size metrics (only available with PE)
if [ -f "${intermediateDir}/*.insert_size_metrics" ]
then
	for sample in "${externalSampleID[@]}"
	do
		cp ${intermediateDir}/${sample}.merged.dedup.bam.insert_size_metrics ${projectResultsDir}/qc/statistics/
	done
fi
echo "Copied insert size metrics (6/11)"


# Copy variants vcf and tables to results directory
cp ${projectPrefix}.final.vcf ${projectResultsDir}/variants/
cp ${projectPrefix}.final.vcf.table ${projectResultsDir}/variants/
if [ -f "${projectPrefix}.delly.snpeff.hpo.vcf" ]
then
	cp ${projectPrefix}.delly.snpeff.hpo.vcf ${projectResultsDir}/variants/
fi
echo "Copied variants vcf and tables to results directory (7/11)"

#copy vcf file + coveragePerBase.txt
for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.final.vcf ${projectResultsDir}/variants/
	cp ${intermediateDir}/${sample}.final.vcf.table ${projectResultsDir}/variants/

	for i in $(ls ${intermediateDir}/${sample}.*.coveragePerBase.txt )
	do
		cp $i ${projectResultsDir}/coverage/
	done

	for i in $(ls ${intermediateDir}/${sample}.*.coveragePerTarget.txt )
	do
		cp $i ${projectResultsDir}/coverage/
	done	
	
done
echo "Copied vcf file + coveragePerBase.txt (8/11)"


# print README.txt files

# Copy QC report to results directory
cp ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}
cp ${projectQcDir}/${project}_QCReport.html ${projectResultsDir}
cp -r ${projectQcDir}/images ${projectResultsDir}
echo "Copied QC report to results directory (9/11)"

# Create zip file for all "small text" files
CURRENT_DIR=`pwd`
cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip variants
zip -gr ${projectResultsDir}/${project}.zip qc
zip -gr ${projectResultsDir}/${project}.zip images
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
#zip -g ${projectResultsDir}/${project}.zip README.pdf
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.md
zip -gr ${projectResultsDir}/${project}.zip coverage

echo "Made zip file: ${projectResultsDir}/${project}.zip (10/11)"

# Create md5sum for zip file

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
echo "Made md5 file for ${projectResultsDir}/${project}.zip (11/11)"
# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}

cd ${CURRENT_DIR}
touch ${logsDir}/${filePrefix}.pipeline.finished
host=$(hostname)
. $EBROOTNGS_DNA/automated/${host}.cfg
printf "The results can be found: ${projectResultsDir}\n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${project} on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
