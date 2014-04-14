
#MOLGENIS walltime=00:10:00
#FOREACH project

#
# Change permissions.
#
umask 0007


#
# Copy data from permanent directories to temp
#
# For each sequence file (could be multiple per sample):
#

<#list internalSampleID as sample>
	<#if seqType[sample_index] == "SR">
		<#if barcode[sample_index] == "None">
			mkdir -p ${allRawNgsDataDir}/${runPrefix[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenameSR[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenameSR[sample_index]} ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenameSR[sample_index]}
			
			# Also add a symlink for the alignment step:
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]}
		<#else>
			mkdir -p ${allRawNgsDataDir}/${runPrefix[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenameSR[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenameSR[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenameSR[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenameSR[sample_index]}
			
			# Also add a symlink for the alignment step:
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenameSR[sample_index]}
		</#if>
		
	<#elseif seqType[sample_index] == "PE">
		
		<#if barcode[sample_index] == "None">
			mkdir -p ${allRawNgsDataDir}/${runPrefix[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE1[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE1[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE2[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedFastqFilenamePE2[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE1[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE1[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE2[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${fastqChecksumFilenamePE2[sample_index]}
		<#else>
			mkdir -p ${allRawNgsDataDir}/${runPrefix[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE1[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE1[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE2[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${compressedDemultiplexedSampleFastqFilenamePE2[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE1[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE1[sample_index]}
			cp ${allPrmRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE2[sample_index]} ${allRawNgsDataDir}/${runPrefix[sample_index]}/${demultiplexedSampleFastqChecksumFilenamePE2[sample_index]}
		</#if>
		
	</#if>
	
</#list>

