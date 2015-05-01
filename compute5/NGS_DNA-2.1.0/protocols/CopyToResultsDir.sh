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
#list seqType

# Change permissions

umask 0007

# Make result directories
mkdir -p ${projectResultsDir}/alignment/
mkdir -p ${projectResultsDir}/coverage/
mkdir -p ${projectResultsDir}/qc/statistics/
mkdir -p ${projectResultsDir}/variants/
mkdir -p ${projectResultsDir}/Pindel/

# Copy error, out and finished logs to project jobs directory

cp ${projectJobsDir}/*.out ${projectLogsDir}
cp ${projectJobsDir}/*.err ${projectLogsDir}
cp ${projectJobsDir}/*.log ${projectLogsDir}

# Copy project csv file to project results directory

cp ${projectJobsDir}/${project}.csv ${projectResultsDir}

# Copy fastQC output to results directory

	cp ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/qc/


for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam ${projectResultsDir}/alignment/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bai ${projectResultsDir}/alignment/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.md5 ${projectResultsDir}/alignment/
done

# Copy alignment stats (lane and sample) to results directory

for sample in "${externalSampleID[@]}"
do
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.alignment_summary_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.gc_bias_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.quality_by_cycle_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.quality_distribution_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.hs_metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.bam_index_stats ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}.merged.dedup.metrics ${projectResultsDir}/qc/statistics/
	cp ${intermediateDir}/${sample}*.pdf ${projectResultsDir}/qc/statistics/
done
	
#only available with PE

        if [ -f "${intermediateDir}/*.insert_size_metrics" ]
        then
		for sample in "${externalSampleID[@]}"
		do
			cp ${intermediateDir}/${sample}.merged.dedup.realigned.bam.insert_size_metrics ${projectResultsDir}/qc/statistics/
		done
        fi


# Copy variants vcf and tables to results directory

	cp ${projectPrefix}.final.vcf ${projectResultsDir}/variants/
	cp ${projectPrefix}.final.vcf.table ${projectResultsDir}/variants/

for sample in "${externalSampleID[@]}"
do	
	cp ${intermediateDir}/${sample}.final.vcf ${projectResultsDir}/variants/
	cp ${intermediateDir}/${sample}.final.vcf.table ${projectResultsDir}/variants/
		
	
	if [ -f ${intermediateDir}/${sample}.coveragePerBase.txt  ] 
	then
		cp ${intermediateDir}/${sample}.coveragePerBase.txt ${projectResultsDir}/coverage/
	fi
	
	if [ ${seqType} == "PE" ]
	then
		cp ${intermediateDir}/${sample}.output.pindel.merged.vcf ${projectResultsDir}/Pindel/
	fi
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

COVPERBASE=`ls ${projectResultsDir}/coverage/*.coveragePerBase.txt | wc -l`

zip -gr ${projectResultsDir}/${project}.zip variants
zip -gr ${projectResultsDir}/${project}.zip qc
zip -gr ${projectResultsDir}/${project}.zip images
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
#zip -g ${projectResultsDir}/${project}.zip README.pdf
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.md
if [ $COVPERBASE > 0 ]
then
        zip -gr ${projectResultsDir}/${project}.zip ${projectResultsDir}/coverage/*.coveragePerBase.txt
fi


# Create md5sum for zip file

cd ${projectResultsDir}

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5

# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}

