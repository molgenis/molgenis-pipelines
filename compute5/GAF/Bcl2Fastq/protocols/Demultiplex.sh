#
# =============================================================================
# Demultiplex GAF-barcoded samples using a custom R script.
#  * Demultiplexes samples mixed in a lane
#  * Uses line count checks both for the input (lane) FastQ files
#    as well as for the created sample FastQ files.
#  * Creates md5 checksums for the created sample FastQ files.
# =============================================================================
#

#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=60:00:00 nodes=1 cores=2 mem=1

#
##
### parameters mapping.
##
#

#string umask
#string runResultsDir
#string seqType
#list barcode
#string filenamePrefix
#list compressedDemultiplexedDiscardedFastqFilenameSR
#list compressedDemultiplexedDiscardedFastqFilenamePE1
#list compressedDemultiplexedDiscardedFastqFilenamePE2
#list demultiplexedSampleFastqChecksumFilenamePE1
#list demultiplexedSampleFastqChecksumFilenamePE2
#list compressedDemultiplexedSampleFastqFilenamePE1
#list compressedDemultiplexedSampleFastqFilenamePE2
#list compressedDemultiplexedSampleFastqFilenameSR
#string filenameSuffixDiscardedReads
#list barcodeType
#string demultiplexScript
#string compressedFastqFilenameSR
#string compressedFastqFilenamePE1
#string compressedFastqFilenamePE2
#string run
#string flowcell
#list lane
#string runJobsDir

echo "umask: ${umask}"
echo "runResultsDir: ${runResultsDir}"
echo "seqType: ${seqType}"
echo "barcode: ${barcode}"
echo "filenamePrefix: ${filenamePrefix}"
echo "compressedDemultiplexedDiscardedFastqFilenameSR: ${compressedDemultiplexedDiscardedFastqFilenameSR[@]}"
echo "compressedDemultiplexedDiscardedFastqFilenamePE1: ${compressedDemultiplexedDiscardedFastqFilenamePE1[@]}"
echo "compressedDemultiplexedDiscardedFastqFilenamePE2: ${compressedDemultiplexedDiscardedFastqFilenamePE2[@]}"
echo "demultiplexedSampleFastqChecksumFilenamePE1: ${demultiplexedSampleFastqChecksumFilenamePE1[@]}"
echo "demultiplexedSampleFastqChecksumFilenamePE2: ${demultiplexedSampleFastqChecksumFilenamePE2[@]}"
echo "compressedDemultiplexedSampleFastqFilenamePE1: ${compressedDemultiplexedSampleFastqFilenamePE1[@]}"
echo "compressedDemultiplexedSampleFastqFilenamePE2: ${compressedDemultiplexedSampleFastqFilenamePE2[@]}"
echo "filenameSuffixDiscardedReads: ${filenameSuffixDiscardedReads}"
echo "barcodeType: ${barcodeType[@]}"
echo "demultiplexScript: ${demultiplexScript}"
echo "compressedFastqFilenameSR: ${compressedFastqFilenameSR}"
echo "compressedFastqFilenamePE1: ${compressedFastqFilenamePE1}"
echo "compressedFastqFilenamePE2: ${compressedFastqFilenamePE2}"
echo "run: ${run}"
echo "flowcell: ${flowcell}"
echo "lane: ${lane[@]}"
echo "runJobsDir: ${runJobsDir}"

#
##
### Custom functions.
##
#

csv_with_prefix(){
	declare -a items=("${!1}")
	declare -x prefix=$2
	declare -x result=""

	((n_elements=${#items[@]}, max_index=n_elements - 1))
	for ((item = 0; item <= max_index; item++))
	do
		if (( $item == max_index ))
		then
			result+="$prefix${items[$item]}"
		else
			result+="$prefix${items[$item]},"
		fi
	done
	
	echo "$result"
}

csv(){
	declare -a items=("${!1}")
	declare -x result=""

	((n_elements=${#items[@]}, max_index=n_elements - 1))
	for ((item = 0; item <= max_index; item++))
	do
		if (( $item == max_index ))
		then
			result+="${items[$item]}"
		else
			result+="${items[$item]},"
		fi
	done

	echo "$result"
}

_count_reads() {
	local    _fastq=$1
	local    _barcode=$2
	local -i _lines=$(gzip -cd ${_fastq} | wc -l)
	local -i _reads=$((${_lines}/4))
	if [ ${#_reads} -gt ${longest_read_count_length} ]; then
		longest_read_count_length=${#_reads}
	fi

	if [ ${#barcode} -gt ${longest_barcode_length} ]; then
		longest_barcode_length=${#barcode}
	fi
	eval "$3=${_reads}"
}

_save_log() {
	local -i _fixed_extra_line_length=13
	local -i _longest_barcode_length=$1
	local -i _longest_read_count_length=$2
	local -i _max_line_length=$((${_fixed_extra_line_length}+${_longest_barcode_length}+${_longest_read_count_length}))
	local    _col_header="$3"
	local    _prefix='INFO:'
	local    _sep=`echo -n ${_prefix}; eval printf '=%.0s' {1..$_max_line_length}; echo`
	local -i _total=$4
	local    _label="$5"
	local    _log_file="$6"
	local -a _counts=("${!7}")
	echo "${_prefix} Demultiplex statistics for:" > ${log}
	echo "${_prefix} ${_label}" >> ${log}
	echo "${_sep}" >> ${log}
	printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}s      (%%)\n" 'Barcode' "${_col_header}" >> ${log}
	echo "${_sep}" >> ${log}
	for _item in "${_counts[@]}"
	do
		local _barcode=${_item%%:*}
		local _count=${_item#*:}
		local _percentage=$(echo "scale=4; ${_count}/${_total}*100" | bc -l)
		printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}d  (%4.1f%%)\n" ${_barcode} ${_count} ${_percentage} >> ${log}
	done
	echo "${_sep}" >> ${log}
}

#
##
### Main
##
#


#
# Initialize script specific vars.
#
RESULTDIR=${runResultsDir[0]}
SCRIPTNAME=${taskId}
FLUXDIR=${RESULTDIR}/${SCRIPTNAME}_in_flux/
fluxDir=${FLUXDIR}

#
# Should I stay or should I go?
#
if [ -f "${runJobsDir}/${SCRIPTNAME}.sh.finished" ]
then
	# Skip this job script.
	echo "${runJobsDir}/${SCRIPTNAME}.sh.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

#
# For each lane demultiplex rawdata.
#
if [[ "$seqType" == "SR" ]]
then
	if [[ "$barcode" == "None" ]]
	then
		#
		# No barcodes used in this lane: Do nothing.
		#
		touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	elif [[ "$barcodeType" == "RPI" || "$barcodeType" == "MON" || "$barcodeType" == "AGI" ]]
	then
		#
		# Illumina-style demultiplexed files:
		#
		#  * Do not demultiplex, but 
		#  * Create a log file with demultiplex statistics.
		#
		# Check if the files required for the read count check are present.
		#
		getFile "${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}"
		
		((n_elements=${#compressedDemultiplexedSampleFastqFilenameSR[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			getFile "${runResultsDir}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck]}"
		done
				
		declare    label=${filenamePrefix}
		declare -a read_counts
		declare -i total_reads=0
		declare -i longest_read_count_length=5
		declare -i longest_barcode_length=7
		
		#
		# Read counts of the demultiplexed files.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		#
		declare    barcode=${filenameSuffixDiscardedReads}
		declare    fastq=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}
		declare -i reads=-1
		_count_reads ${fastq} ${barcode} 'reads'
		read_counts=(${read_counts[@]-} ${barcode}:${reads})
		((total_reads+=${reads}))
		
		((n_elements=${#compressedDemultiplexedSampleFastqFilenameSR[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			barcode=${barcode[fileToCheck]}
			fastq=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck]}
			declare -i reads=-1
			_count_reads ${fastq} ${barcode} 'reads'
			read_counts=(${read_counts[@]-} ${barcode}:${reads})
			((total_reads+=${reads}))
		done
				
		declare log=${FLUXDIR}/${label}.demultiplex.log
		_save_log ${longest_barcode_length} ${longest_read_count_length} 'Reads' ${total_reads} ${label} ${log} 'read_counts[@]'
		
	
	elif [[	"$barcodeType" == "GAF" ]]
	then
		#
		# Setup environment for tools we need.
		#
		module load R
		module list
		
		#
		# Check if the files required for demultiplexing are present.
		#
		getFile "${runResultsDir}/${compressedFastqFilenameSR}"
		
		#
		# Read count of the input file.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		#
		reads_in_1=$(gzip -cd ${runResultsDir}/${compressedFastqFilenameSR} | wc -l)
		
		#
		# Demultiplex the multiplexed, gzipped FastQ file.
		#
		Rscript ${demultiplexScript} --bcs csv barcode[@] \
		--mpr1 "${runResultsDir}/${compressedFastqFilenameSR}" \
		--dmr1 "csv_with_prefix ${compressedDemultiplexedSampleFastqFilenameSR[@]} $fluxDir" \
		--ukr1 "${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}" \
		--tm MP \
		> ${fluxDir}/${filenamePrefix}.demultiplex.log
		
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
		
		
		((n_elements=${#demultiplexedSampleFastqFilenameSR[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			this_read_count=0
			mkfifo ${fluxDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck]}.pipe
			md5sum <${fluxDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck]}.pipe | \
				sed "s/ -/ ${fileToCheck}/" > ${fluxDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck]} &
			this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck]} | \
				tee ${fluxDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck]}.pipe | \
				wc -l)
			rm ${fluxDir}/${demultiplexedSampleFastqChecksumFilenameSR[fileToCheck]}.pipe
			summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		done
		
		#
		# Same for the discarded, uncompressed FastQ file.
		#
		this_read_count=0
		mkfifo ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe
		md5sum <${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe | \
			sed "s/ -/ ${demultiplexedDiscardedFastqFilenameSR}/" > ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenameSR} &
		this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR} | \
			tee ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe | \
			wc -l)
		rm ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenameSR}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		
		#
		# Flush disk caches to disk to make sure we don't loose any demultiplexed data 
		# when a machine crashes and some of the "written" data was in a write buffer.
		#
		sync
		
		#
		# Read count sanity check.
		#
		if (( $reads_in_1 == $summed_reads_out_1 )); then
			touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.passed
		else
			touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
			exit 1
		fi
	else	
		#
		# Found unknown barcode type!
		#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1
	fi

elif [[ "$seqType" == "PE" ]]
then		
	if [[ "$barcode" == "None" ]]
	then
		#
		# No barcodes used in this lane: Do nothing.
		#
		touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	
	elif [[ "$barcodeType" == "RPI" || "$barcodeType" == "MON" || "$barcodeType" == "AGI" ]]
	then
	
		#
		# Illumina-style demultiplexed files:
		#
		#  * Do not demultiplex, but 
		#  * Perform a read count check between reads 1 and 2 and
		#  * Create a log file with demultiplex statistics.
		#
		# Check if the files required for the read count check are present.
		#
		getFile "${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}"
		getFile "${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}"
		
		((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE1[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			getFile "${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck]}"
		done
		
		((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE2[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			getFile "${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck]}"
		done
				
		declare    label=${filenamePrefix}
		declare -a read_pair_counts
		declare -i total_read_pairs=0
		declare -i longest_read_count_length=10
		declare -i longest_barcode_length=7
		
		#
		# Read count sanity check of the demultiplexed files.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		# For PE data the amount of reads in both files must be the same!
		#
		declare    barcode=${filenameSuffixDiscardedReads}
		declare    fastq_1=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}
		declare    fastq_2=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}
		declare -i reads_1=-1
		declare -i reads_2=-2
		_count_reads ${fastq_1} ${barcode} 'reads_1'
		_count_reads ${fastq_2} ${barcode} 'reads_2'
		if (( $reads_1 != $reads_2)); then
			touch ${fluxDir}/${label}_${barcode}.read_count_check_for_pairs.FAILED
			echo "FATAL: Number of reads in both ${label}_${barcode} FastQ files not the same!"
			exit 1
		fi
		read_pair_counts=(${read_pair_counts[@]-} ${barcode}:${reads_1})
		((total_read_pairs+=$reads_1))
		
		((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE1[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
		barcode=${barcode[fileToCheck]}
		fastq_1=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck]}
		fastq_2=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck]}
		reads_1=-1
		reads_2=-2
		_count_reads ${fastq_1} ${barcode} 'reads_1'
		_count_reads ${fastq_2} ${barcode} 'reads_2'
		if (( $reads_1 != $reads_2)); then
			touch ${fluxDir}/${label}_${barcode}.read_count_check_for_pairs.FAILED
			echo "FATAL: Number of reads in both ${label}_${barcode} FastQ files not the same!"
			exit 1
		fi
		read_pair_counts=(${read_pair_counts[@]-} ${barcode}:${reads_1})
		((total_read_pairs+=$reads_1))
		
		done
				
		declare log=${FLUXDIR}/${label}.demultiplex.log
		_save_log ${longest_barcode_length} ${longest_read_count_length} 'Read Pairs' ${total_read_pairs} ${label} ${log} 'read_pair_counts[@]'
		
		
		touch ${fluxDir}/${filenamePrefix}.read_count_check_for_pairs.passed
	
	elif [[ "$barcodeType" == "GAF" ]]
	then
		#
		# Setup environment for tools we need.
		#
		module load R
		module list
		
		#
		# Check if the files required for demultiplexing are present.
		#
		getFile "${runResultsDir}/${compressedFastqFilenamePE1}"
		getFile "${runResultsDir}/${compressedFastqFilenamePE2}"
		
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
		if (( $reads_in_1 != $reads_in_2)); then
			touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
			echo "FATAL: cannot demultiplex ${filenamePrefix}. Number of reads in both specified PE FastQ input files not the same!"
			exit 1
		fi
		
		#
		# Demultiplex the multiplexed, gzipped FastQ file.
		#
		Rscript ${demultiplexScript} --bcs csv barcode[@] \
		--mpr1 "${runResultsDir}/${compressedFastqFilenamePE1}" \
		--mpr2 "${runResultsDir}/${compressedFastqFilenamePE2}" \
		--dmr1 "csv_with_prefix compressedDemultiplexedSampleFastqFilenamePE1[@] $fluxDir" \
		--dmr2 "csv_with_prefix compressedDemultiplexedSampleFastqFilenamePE2[@] $fluxDir" \
		--ukr1 "${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}" \
		--ukr2 "${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}" \
		--tm MP \
		> ${fluxDir}/${filenamePrefix}.demultiplex.log
		
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
		((n_elements=${#demultiplexedSampleFastqFilenamePE1[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			this_read_count=0
			mkfifo ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]}.pipe
			md5sum <${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]}.pipe | \
			sed "s/ -/ ${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]}/" > ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]} &
			this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck]} | \
			tee ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]}.pipe | \
			wc -l)
			rm ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE1[fileToCheck]}.pipe
			summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		done
		
		((n_elements=${#demultiplexedSampleFastqFilenamePE2[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			this_read_count=0
			mkfifo ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]}.pipe
			md5sum <${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]}.pipe | \
			sed "s/ -/ ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]}/" > ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]} &
			this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck]} | \
			tee ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]}.pipe | \
			wc -l)
			rm ${fluxDir}/${demultiplexedSampleFastqChecksumFilenamePE2[fileToCheck]}.pipe
			summed_reads_out_2=$(( $summed_reads_out_2 + $this_read_count ))
		
		done
		
		#
		# Same for the discarded, uncompressed FastQ files.
		#
		this_read_count=0
		mkfifo ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe
		md5sum <${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe | \
		sed "s/ -/ ${demultiplexedDiscardedFastqFilenamePE1}/" > ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1} &
		this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1} | \
		tee ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe | \
		wc -l)
		rm ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE1}.pipe
		summed_reads_out_1=$(( $summed_reads_out_1 + $this_read_count ))
		
		this_read_count=0
		mkfifo ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe
		md5sum <${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe | \
		sed "s/ -/ ${demultiplexedDiscardedFastqFilenamePE2}/" > ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2} &
		this_read_count=$(gzip -cd ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2} | \
		tee ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe | \
		wc -l)
		rm ${fluxDir}/${demultiplexedDiscardedFastqChecksumFilenamePE2}.pipe
		summed_reads_out_2=$(( $summed_reads_out_2 + $this_read_count ))
		
		#
		# Flush disk caches to disk to make sure we don't loose any demultiplexed data 
		# when a machine crashes and some of the "written" data was in a write buffer.
		#
		sync
		
		#
		# Read count sanity check.
		#
		if (( $reads_in_1 == $summed_reads_out_1 )) && (( $reads_in_2 == $summed_reads_out_2)); then
			touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.passed
		else 
			touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.FAILED
			exit 1
		fi

	else
	
		#
		# Found unknown barcode type!
		#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1

	fi

fi	


#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${fluxDir}/* ${RESULTDIR}/
rmdir ${fluxDir}
sync