
#MOLGENIS walltime=66:00:00 nodes=1 cores=4 mem=12
#FOREACH externalSampleID

inputs "${mergedbam}" "${mergedbamindex}" "${indexfile}"
inputs "${targetintervals}"

alloutputsexist "${coveragegatk}" \
"${coveragegatk}.sample_cumulative_coverage_counts" \
"${coveragegatk}.sample_cumulative_coverage_proportions" \
"${coveragegatk}.sample_interval_statistics" \
"${coveragegatk}.sample_interval_summary" \
"${coveragegatk}.sample_statistics" \
"${coveragegatk}.sample_summary" \
"${coveragegatk}.cumulative_coverage.pdf"

module load R/2.14.2
module load GATK/1.0.5069
module list

java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
$GATK_HOME/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R ${indexfile} \
-I ${mergedbam} \
-o ${coveragegatk} \
-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50 \
-L ${targetintervals} 

#Create coverage graphs for sample
$RHOME/bin/Rscript ${cumcoveragescriptgatk} \
--in ${coveragegatk}.sample_cumulative_coverage_proportions \
--out ${coveragegatk}.cumulative_coverage.pdf \
--max-depth 100 \
--title "Cumulative coverage ${externalSampleID}"
