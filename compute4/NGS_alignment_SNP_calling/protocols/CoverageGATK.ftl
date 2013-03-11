#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=66:00:00 nodes=1 cores=1 mem=12
#FOREACH externalSampleID

inputs "${mergedbam}" "${mergedbamindex}" "${indexfile}"
<#if capturingKit != "None">inputs "${targetintervals}"</#if>
alloutputsexist "${coveragegatk}" \
"${coveragegatk}.sample_cumulative_coverage_counts" \
"${coveragegatk}.sample_cumulative_coverage_proportions" \
"${coveragegatk}.sample_interval_statistics" \
"${coveragegatk}.sample_interval_summary" \
"${coveragegatk}.sample_statistics" \
"${coveragegatk}.sample_summary" \
"${coveragegatk}.cumulative_coverage.pdf"

export PATH=${JAVA_HOME}/bin:<#noparse>${PATH}</#noparse>
export PATH=${R_HOME}/bin:<#noparse>${PATH}</#noparse>
export R_LIBS=${R_LIBS}

java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
${genomeAnalysisTKjar} \
-T DepthOfCoverage \
-R ${indexfile} \
-I ${mergedbam} \
-o ${coveragegatk} \
-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50<#if capturingKit != "None"> \
-L ${targetintervals}</#if>

#Create coverage graphs for sample
${rscript} ${cumcoveragescriptgatk} \
--in ${coveragegatk}.sample_cumulative_coverage_proportions \
--out ${coveragegatk}.cumulative_coverage.pdf \
--max-depth 100 \
--title "Cumulative coverage ${externalSampleID}"
