#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=1:00:00 nodes=1 cores=1 mem=1
#FOREACH flowcell, lane, seqType, filenamePrefix

#
# For each lane.
#
<#if seqType == "SR">
	
	#
	# Check the complete lane files.
	#
	ls ${allRawNgsDataDir}/${runPrefix}/${compressedFastqFilenameSR}
	ls ${allRawNgsDataDir}/${runPrefix}/${fastqChecksumFilenameSR}
	
	<#if barcode[0] == "None">
	<#else>
		#
		# Check demultiplexing success.
		#
		ls ${allRawNgsDataDir}/${runPrefix}/${filenamePrefix}.demultiplex.read_count_check.passed
		ls ${allRawNgsDataDir}/${runPrefix}/${filenamePrefix}.demultiplex.log
	
		#
		# For the demultiplexed sample FastQ files:
		#
		<#list demultiplexedSampleFastqFilenameSR as fileToCheck>
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck_index]}
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]}
		</#list>
		
		#
		# Same for the discarded reads FastQ file.
		#
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedDiscardedFastqChecksumFilenameSR}
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedDiscardedFastqFilenameSR}
		
	</#if>
	
<#elseif seqType == "PE">
	
	#
	# Check the complete lane files.
	#
	ls ${allRawNgsDataDir}/${runPrefix}/${compressedFastqFilenamePE1}
	ls ${allRawNgsDataDir}/${runPrefix}/${compressedFastqFilenamePE2}
	ls ${allRawNgsDataDir}/${runPrefix}/${fastqChecksumFilenamePE1}
	ls ${allRawNgsDataDir}/${runPrefix}/${fastqChecksumFilenamePE2}
	
	<#if barcode[0] == "None">
	<#else>
		#
		# Check demultiplexing success.
		#
		ls ${allRawNgsDataDir}/${runPrefix}/${filenamePrefix}.demultiplex.read_count_check.passed
		ls ${allRawNgsDataDir}/${runPrefix}/${filenamePrefix}.demultiplex.log
		
		#
		# For the demultiplexed sample FastQ files:
		#
		<#list demultiplexedSampleFastqFilenamePE1 as fileToCheck>
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck_index]}
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]}
		</#list>
		<#list demultiplexedSampleFastqFilenamePE2 as fileToCheck>
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck_index]}
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]}
		</#list>
		
		#
		# Same for the discarded reads FastQ file.
		#
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedDiscardedFastqFilenamePE1}
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedDiscardedFastqChecksumFilenamePE1}
		
		ls ${allRawNgsDataDir}/${runPrefix}/${compressedDemultiplexedDiscardedFastqFilenamePE2}
		ls ${allRawNgsDataDir}/${runPrefix}/${demultiplexedDiscardedFastqChecksumFilenamePE2}
		
	</#if>
	
</#if>
