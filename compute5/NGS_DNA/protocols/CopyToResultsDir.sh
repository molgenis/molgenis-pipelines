#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping
#string tmpName
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
#string automateVersion
# Change permissions

umask 0007

module load ${automateVersion}

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

# Make result directories
mkdir -p ${projectResultsDir}/alignment/
mkdir -p ${projectResultsDir}/coverage/
mkdir -p ${projectResultsDir}/qc/statistics/
mkdir -p ${projectResultsDir}/variants/
#mkdir -p ${projectResultsDir}/Pindel/


UNIQUESAMPLES=()
for samples in "${externalSampleID[@]}"
do
  	array_contains UNIQUESAMPLES "$samples" || UNIQUESAMPLES+=("$samples")    # If bamFile does not exist in array add it
done

EXTERN=${#UNIQUESAMPLES[@]}

# Copy error, out and finished logs to project jobs directory
printf "Copying out, error and finished logs to project jobs directory.."
rsync -a ${projectJobsDir}/*.out ${projectLogsDir}
rsync -a ${projectJobsDir}/*.err ${projectLogsDir}
rsync -a ${projectJobsDir}/*.log ${projectLogsDir}
printf ".. finished! (1/11)\n"

# Copy project csv file to project results directory
printf "Copied project csv file to project results directory.."
rsync -a ${projectJobsDir}/${project}.csv ${projectResultsDir}
printf ".. finished (2/11)\n"

# Copy fastQC output to results directory
printf "Copying fastQC output to results directory.."
rsync -a ${intermediateDir}/*_fastqc.zip ${projectResultsDir}/qc/
printf ".. finished (3/11)\n"

count=1
#copy realigned bams
printf "Copying ${EXTERN} realigned bams "
for sample in "${UNIQUESAMPLES[@]}"
do
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam ${projectResultsDir}/alignment/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.bai ${projectResultsDir}/alignment/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.md5 ${projectResultsDir}/alignment/
	printf "."
done
printf " finished (4/11)\n"

# Copy alignment stats (lane and sample) to results directory

count=1
printf "Copying alignment stats (lane and sample) to results directory "
for sample in "${UNIQUESAMPLES[@]}"
do
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.alignment_summary_metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.gc_bias_metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.quality_by_cycle_metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.quality_distribution_metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.hs_metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.bam_index_stats ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}.merged.dedup.metrics ${projectResultsDir}/qc/statistics/
	rsync -a ${intermediateDir}/${sample}*.pdf ${projectResultsDir}/qc/statistics/
	printf "."
done
	printf " finished (5/11)\n"

#copy insert size metrics (only available with PE)

if [ -f "${intermediateDir}/*.insert_size_metrics" ]
then
	printf "Copying insert size metrics "
	for sample in "${UNIQUESAMPLES[@]}"
	do
		rsync -a ${intermediateDir}/${sample}.merged.dedup.bam.insert_size_metrics ${projectResultsDir}/qc/statistics/
		printf "."
	done
	printf " finished (6/11)\n"
else
	printf "no insert size metrics available, skipped (6/11)\n"
fi

printf "Copying variants vcf and tables to results directory "
# Copy variants vcf and tables to results directory
rsync -a ${projectPrefix}.final.vcf ${projectResultsDir}/variants/
printf "."
rsync -a ${projectPrefix}.final.vcf.table ${projectResultsDir}/variants/
printf "."
if [ -f "${projectPrefix}.delly.snpeff.hpo.vcf" ]
then
	rsync -a ${projectPrefix}.delly.snpeff.hpo.vcf ${projectResultsDir}/variants/
	printf "."
fi
printf " finished (7/11)\n"

#copy vcf file + coveragePerBase.txt
printf "Copying vcf files and coverage per base and per target files "
for sample in "${UNIQUESAMPLES[@]}"
do
	rsync -a ${intermediateDir}/${sample}.final.vcf ${projectResultsDir}/variants/
	printf "."
	rsync -a ${intermediateDir}/${sample}.final.vcf.table ${projectResultsDir}/variants/
	printf "."
	if ls ${intermediateDir}/${sample}.*.coveragePerBase.txt 1> /dev/null 2>&1
	then
		for i in $(ls ${intermediateDir}/${sample}.*.coveragePerBase.txt )
		do
			rsync -a $i ${projectResultsDir}/coverage/
			printf "."
		done
	
	else
		echo "coveragePerBase skipped for sample: ${sample}"
	fi
	
	if ls ${intermediateDir}/${sample}.*.coveragePerTarget.txt 1> /dev/null 2>&1
        then
		for i in $(ls ${intermediateDir}/${sample}.*.coveragePerTarget.txt )
		do
			rsync -a $i ${projectResultsDir}/coverage/
			printf "."
		done	
	else
		 echo "coveragePerTarget skipped for sample: ${sample}"
	fi
	
done
printf " finished (8/11)\n"


# print README.txt files
printf "Copying QC report to results directory "

# Copy QC report to results directory
rsync -a ${projectQcDir}/${project}_QCReport.pdf ${projectResultsDir}
printf "."
rsync -a ${projectQcDir}/${project}_QCReport.html ${projectResultsDir}
printf "."
rsync -ra ${projectQcDir}/images ${projectResultsDir}
printf " finished (9/11)\n"

echo "Creating zip file"
# Create zip file for all "small text" files
CURRENT_DIR=`pwd`
cd ${projectResultsDir}

zip -gr ${projectResultsDir}/${project}.zip variants
zip -gr ${projectResultsDir}/${project}.zip qc
zip -gr ${projectResultsDir}/${project}.zip images
zip -g ${projectResultsDir}/${project}.zip ${project}.csv
#zip -g ${projectResultsDir}/${project}.zip README.pdf
zip -g ${projectResultsDir}/${project}.zip ${project}_QCReport.pdf
zip -gr ${projectResultsDir}/${project}.zip coverage

echo "Zip file created: ${projectResultsDir}/${project}.zip (10/11)"

# Create md5sum for zip file

md5sum ${project}.zip > ${projectResultsDir}/${project}.zip.md5
echo "Made md5 file for ${projectResultsDir}/${project}.zip (11/11)"
# add u+rwx,g+r+w rights for GAF group

chmod -R u+rwX,g+rwX ${projectResultsDir}

cd ${CURRENT_DIR}

host=$(hostname)
if [[ "${host}" == *"umcg-"* || "${host}" == "calculon" ]]
then
	echo "automating the pipeline is not implemented on calculon yet"
        
elif [[ "${host}" == *"gd-node"* || "${host}" == "zinc-finger.gcc.rug.nl" ]]
then

	if [[ "${logsDir}" == *"/groups/umcg-gd"* ]]
	then
		. ${EBROOTAUTOMATED}/parameters_gd.csv
	elif [[ "${logsDir}" == *"/groups/umcg-gaf"* ]] 
	then
		. ${EBROOTAUTOMATED}/parameters_gaf.csv
	else
		echo "unknown groupname please run in gaf or gd"
	fi

	touch ${logsDir}/${project}.pipeline.finished
        . ${EBROOTAUTOMATED}/zinc-finger.gcc.rug.nl.cfg
        . $EBROOTAUTOMATED/sharedConfig.cfg
	echo "pipeline is finished, user ${ONTVANGER} has been mailed"
        printf "The results can be found: ${projectResultsDir}\n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${project} on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
else
	echo "unknown host"
fi
