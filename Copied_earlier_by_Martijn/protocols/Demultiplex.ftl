#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate 20120807$
# $LastChangedRevision$
# $LastChangedBy WBKoetsier$
# =====================================================
#

#MOLGENIS walltime=48:00:00 nodes=1 cores=4 mem=1
#FOREACH flowcell, lane, seqType, filenamePrefix

export PATH=${R_HOME}/bin:<#noparse>${PATH}</#noparse>

#
# Check if we need to run this step or wether demultiplexing was already executed successfully in a previous run.
#
# Note: we don't check for presence of the actual demultiplexed reads, but for empty file indicating successfull demultipxing instead 
#       where success is based on a comparison of the amount of reads in the multiplexed input file and the total amount of reads in 
#       the demultiplexed output files: these counts should be the same.
#
alloutputsexist "${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.passed"

#
# For each lane demultiplex rawdata.
#
<#if seqType == "SR">
	
	<#if barcode[0] == "None">
		#
		# Do nothing.
		#
		touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	<#elseif barcodeType[0] == "RPI">
	    #
	    # Do nothing.
	    #
	    touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	<#elseif barcodeType[0] == "GAF">
		#
		# Check if the files required for demultiplexing are present.
		#
		inputs "${runResultsDir}/${compressedFastqFilenameSR}"
		
		#
		# Read count of the input file.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		#
		reads_in_1=$(gzip -cd ${runResultsDir}/${compressedFastqFilenameSR} | wc -l)
		
		#
		# Demultiplex the multiplexed, gzipped FastQ file.
		#
		Rscript ${demultiplexscript} --bcs '${csv(barcode)}' \
		--mpr1 ${runResultsDir}/${compressedFastqFilenameSR} \
		--dmr1 '${csv(compressedDemultiplexedSampleFastqFilepathSR)}' \
		--ukr1 ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenameSR} \
		--tm MP \
		> ${runResultsDir}/${filenamePrefix}.demultiplex.log
		
		#
		# Read count of the output file.
		#
		summed_reads_out_1=0
		
		#
		# For the demultiplexed, uncompressed FastQ files:
		# 1. Calculate MD5Sums.
		# 2. Count the amount of lines(, which equals to reads * 4) per file.
		# 3. Update the sum of lines of all files.
		#
		<#list demultiplexedSampleFastqFilenameSR as fileToCheck>
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]}.pipe
		md5sum <${runResultsDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]}.pipe | \
			sed 's/ -/ ${fileToCheck}/' > ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck_index]} | \
			tee ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck_index]}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
			
		</#list>
		
		#
		# Same for the discarded, uncompressed FastQ file.
		#
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe
		md5sum <${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe | \
			sed 's/ -/ ${demultiplexedDiscardedFastqFilenameSR}/' > ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenameSR} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenameSR} | \
			tee ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		
		#
		# Flush disk caches to disk to make sure we don't loose any demultiplexed data 
		# when a machine crashes and some of the "written" data was in a write buffer.
		#
		sync
		
		#
		# Read count sanity check.
		#
		if (( $reads_in_1 == $summed_reads_out_1 ))
		then touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.passed
		else touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
		fi
		
	<#else>
		#
		# Found unknown barcode type!
		#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1
	</#if>
	
<#elseif seqType == "PE">
	
	<#if barcode[0] == "None">
		#
		# Do nothing.
		#
		touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	<#elseif barcodeType[0] == "RPI">
	    #
	    # Illumina demultiplexed files: do not demultiplex, but do perform a read count check between reads 1 and 2
	    #
	    # Check if the files required for the read count check are present.
	    #
	    <#list compressedDemultiplexedSampleFastqFilenamePE1 as fileToCheck>
	    	inputs "${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck_index]}"
	    </#list>
	    
	    <#list compressedDemultiplexedSampleFastqFilenamePE2 as fileToCheck>
	    	inputs "${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck_index]}"
	    </#list>
	  	
	  	#
		# Read count of the input file.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		# Read count sanity check for the inputs.
		# For PE data the amount of reads in both input files must be the same!
		#
	    <#list compressedDemultiplexedSampleFastqFilenamePE1 as fileToCheck>
			reads_1=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck_index]} | wc -l)
			reads_2=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck_index]} | wc -l)
			if (( $reads_1 != $reads_2))
				then touch ${runResultsDir}/${filenamePrefix}_${barcode[fileToCheck_index]}.read_count_check.FAILED
				echo "FATAL: Number of reads in both ${filenamePrefix}_${barcode[fileToCheck_index]} FastQ files not the same!"
				exit 1
			fi

		</#list>
	<#elseif barcodeType[0] == "GAF">
		#
		# Check if the files required for demultiplexing are present.
		#
		inputs "${runResultsDir}/${compressedFastqFilenamePE1}"
		inputs "${runResultsDir}/${compressedFastqFilenamePE2}"
	
		#
		# Read count of the input file.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		#
		reads_in_1=$(gzip -cd ${runResultsDir}/${compressedFastqFilenamePE1} | wc -l)
		reads_in_2=$(gzip -cd ${runResultsDir}/${compressedFastqFilenamePE2} | wc -l)
		
		#
		# Read count sanity check for the inputs.
		# For PE data the amount of reads in both input files must be the same!
		#
		if (( $reads_in_1 != $reads_in_2))
		then touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
		echo "FATAL: cannot demultiplex ${filenamePrefix}. Number of reads in both specified PE FastQ input files not the same!"
		exit 1
		fi
		
		#
		# Demultiplex the multiplexed, gzipped FastQ file.
		#
		Rscript ${demultiplexscript} --bcs '${csv(barcode)}' \
		--mpr1 ${runResultsDir}/${compressedFastqFilenamePE1} \
		--mpr2 ${runResultsDir}/${compressedFastqFilenamePE2} \
		--dmr1 '${csv(compressedDemultiplexedSampleFastqFilepathPE1)}' \
		--dmr2 '${csv(compressedDemultiplexedSampleFastqFilepathPE2)}' \
		--ukr1 ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1} \
		--ukr2 ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2} \
		--tm MP \
		> ${runResultsDir}/${filenamePrefix}.demultiplex.log
		
		#
		# Read count of the output file.
		#
		summed_reads_out_1=0
		summed_reads_out_2=0
		
		#
		# For the demultiplexed, uncompressed FastQ files:
		# 1. Calculate MD5Sums.
		# 2. Count the amount of lines(, which equals to reads * 4) per file.
		# 3. Update the sum of lines of all files.
		#
		<#list demultiplexedSampleFastqFilenamePE1 as fileToCheck>
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]}.pipe
		md5sum <${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]}.pipe | \
			sed 's/ -/ ${fileToCheck}/' > ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck_index]} | \
			tee ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck_index]}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		
		</#list>
		<#list demultiplexedSampleFastqFilenamePE2 as fileToCheck>
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]}.pipe
		md5sum <${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]}.pipe | \
			sed 's/ -/ ${fileToCheck}/' > ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck_index]} | \
			tee ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck_index]}.pipe
		summed_reads_out_2=$(( $summed_reads_out_2 + $this_read_count ))
		
		</#list>
		#
		# Same for the discarded, uncompressed FastQ files.
		#
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe
		md5sum <${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe | \
			sed 's/ -/ ${demultiplexedDiscardedFastqFilenamePE1}/' > ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1} | \
			tee ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		
		this_read_count=0
		mkfifo ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe
		md5sum <${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe | \
			sed 's/ -/ ${demultiplexedDiscardedFastqFilenamePE2}/' > ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2} &
		this_read_count=$(gzip -cd ${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2} | \
			tee ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe | \
			wc -l)
		rm ${runResultsDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe
		summed_reads_out_2=$(( $summed_reads_out_2 + $this_read_count ))
		
		#
		# Flush disk caches to disk to make sure we don't loose any demultiplexed data 
		# when a machine crashes and some of the "written" data was in a write buffer.
		#
		sync
		
		#
		# Read count sanity check.
		#
		if (( $reads_in_1 == $summed_reads_out_1 )) && (( $reads_in_2 == $summed_reads_out_2))
		then touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.passed
		else touch ${runResultsDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
		fi

	<#else>
		#
		# Found unknown barcode type!
		#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1

	</#if>
	
</#if>
