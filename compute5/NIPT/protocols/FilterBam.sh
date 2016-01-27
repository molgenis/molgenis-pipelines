#MOLGENIS walltime=23:59:00 mem=4gb ppn=5

#string sambambaVersion
#string sambambaTool
#string inputUtrechtDataRawSample
#string inputDataRawSample
umask 0007

module load sambamba/${sambambaVersion}
module list

#Filter BAM files
${EBROOTSAMBAMBA}/${sambambaTool} view -f bam --filter="mapping_quality >= 40 and [NM]<=1 and [SA] == null" ${inputUtrechtDataRawSample} -o ${inputDataRawSample}
${EBROOTSAMBAMBA}/${sambambaTool} index -t 4 ${inputDataRawSample}
echo "filtered and indexed: ${inputDataRawSample}"
