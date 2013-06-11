#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=29:59:00 nodes=1 cores=1 mem=12
#FOREACH externalSampleID

<#if capturingKit != "None">
getFile "${indexfile}"
getFile "${mergedbam}"
getFile "${mergedbamindex}"
getFile "${targetcoverageintervals1}"
getFile "${targetcoverageintervals2}"

alloutputsexist "${samplecoveragebed}"

#Calculate coverage for first list of bins
java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
${genomeAnalysisTKjar} \
-T DepthOfCoverage \
-R ${indexfile} \
-I ${mergedbam} \
-o ${intervalcoverage1} \
-ct 10 -ct 20 \
-L ${targetcoverageintervals1}

#Calculate coverage for second list of bins
java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
${genomeAnalysisTKjar} \
-T DepthOfCoverage \
-R ${indexfile} \
-I ${mergedbam} \
-o ${intervalcoverage2} \
-ct 10 -ct 20 \
-L ${targetcoverageintervals2}

#Create bed file from coverage interval summary files
perl ${createcoveragebedpl} \
-sample ${externalSampleID} \
-file1 ${intervalcoverage1}.sample_interval_summary \
-file2 ${intervalcoverage2}.sample_interval_summary \
-output ${samplecoveragebed}

putFile "${samplecoveragebed}"

</#if>