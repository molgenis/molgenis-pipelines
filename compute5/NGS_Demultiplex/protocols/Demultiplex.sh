#MOLGENIS walltime=12:00:00 nodes=1 ppn=2 mem=2gb

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
		# No barcodes used in this lane: Do nothing.
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

	else

		#
		# Found unknown barcode type!
		#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1

	fi

fi
