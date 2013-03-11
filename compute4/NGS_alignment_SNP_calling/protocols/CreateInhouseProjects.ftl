#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=00:10:00
#FOREACH project

#
# Change permissions.
#
umask 0007

#
# Create project dirs.
#
mkdir -p ${projectrawarraydatadir}
mkdir -p ${projectrawdatadir}
mkdir -p ${projectJobsDir}
mkdir -p ${projectLogsDir}
mkdir -p ${intermediatedir}
mkdir -p ${projectResultsDir}
mkdir -p ${qcdir}

#
# Create symlinks to the raw data required to analyse this project
#
# For each sequence file (could be multiple per sample):
#
<#list internalSampleID as sample>
	
	<#if seqType[sample_index] == "SR">
		
		<#if barcode[sample_index] == "None">
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]} ${projectrawdatadir}/${compressedFastqFilenameNoBarcodeSR[sample_index]}
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenameSR[sample_index]} ${projectrawdatadir}/${fastqChecksumFilenameNoBarcodeSR[sample_index]}
			
			# Also add a symlink for the alignment step:
			# ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE1[sample_index]} ${projectrawdatadir}/${compressedFastqFilenameNoBarcodePE1[sample_index]}
		<#else>
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenameSR[sample_index]} ${projectrawdatadir}/
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenameSR} ${projectrawdatadir}/
		</#if>
		
	<#elseif seqType[sample_index] == "PE">
		
		<#if barcode[sample_index] == "None">
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE1[sample_index]} ${projectrawdatadir}/${compressedFastqFilenameNoBarcodePE1[sample_index]}
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE2[sample_index]} ${projectrawdatadir}/${compressedFastqFilenameNoBarcodePE2[sample_index]}
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE1[sample_index]} ${projectrawdatadir}/${fastqChecksumFilenameNoBarcodePE1[sample_index]}
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE2[sample_index]} ${projectrawdatadir}/${fastqChecksumFilenameNoBarcodePE2[sample_index]}
		<#else>
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE1[sample_index]} ${projectrawdatadir}/
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE2[sample_index]} ${projectrawdatadir}/
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE1[sample_index]} ${projectrawdatadir}/
			ln -s ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE2[sample_index]} ${projectrawdatadir}/
		</#if>
		
	</#if>
	
</#list>

#
# TODO: array for each sample:
#

#
# Create subset of samples for this project.
#
<#--<#assign unfolded = unfoldParametersCSV(parameters) />
<#list unfolded as sampleSequenceDetails>
echo ${sampleSequenceDetails} >> ${projectJobsDir}/${project}.csv
</#list>-->
${scriptdir}/extract_samples_from_GAF_list.pl --i ${McWorksheet} --o ${projectJobsDir}/${project}.csv --c project --q ${project}

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#
sh ${McDir}/molgenis_compute.sh \
-worksheet=${projectJobsDir}/${project}.csv \
-parameters=${McParameters} \
-workflow=${workflowFile} \
-protocols=${McProtocols}/ \
-system=${McProtocols}/ \
-outputdir=${projectJobsDir}/ \
-id=${McId}
