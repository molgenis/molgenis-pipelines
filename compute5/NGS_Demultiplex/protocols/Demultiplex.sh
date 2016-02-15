#MOLGENIS walltime=12:00:00 nodes=1 ppn=2 mem=2gb

#string runResultsDir
#string seqType
#list barcode
#string filenamePrefix
#string compressedDemultiplexedDiscardedFastqFilenameSR
#string compressedDemultiplexedDiscardedFastqFilenamePE1
#string compressedDemultiplexedDiscardedFastqFilenamePE2
#list demultiplexedSampleFastqChecksumFilenamePE1,demultiplexedSampleFastqChecksumFilenamePE2,compressedDemultiplexedSampleFastqFilenamePE1,compressedDemultiplexedSampleFastqFilenamePE2,compressedDemultiplexedSampleFastqFilenameSR
#string filenameSuffixDiscardedReads
#list barcodeType
#string compressedFastqFilenameSR
#string compressedFastqFilenamePE1
#string compressedFastqFilenamePE2
#string run
#string flowcell
#string lane

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
		local _percentage=$(awk "BEGIN {printf \"%.4f\n\", (($_count/$_total)*100)}")
		printf "${_prefix} %${_longest_barcode_length}s: %${_longest_read_count_length}d  (%4.1f%%)\n" ${_barcode} ${_count} ${_percentage} >> ${log}
	done
	echo "${_sep}" >> ${log}
}

#
# Initialize script specific vars.
#
RESULTDir=${runResultsDir[0]}

makeTmpDir ${runResultsDir}
fluxDir=${MC_tmpFile}

#
# For each lane demultiplex rawdata.
#
if [ "$seqType" == "SR" ]
then
	if [[ "${barcode[0]}" == "None" || "${barcode[0]}" == "" ]]
	then
		# No barcodes used in this lane: Do nothing.
		touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	else
		#
		# Illumina-style demultiplexed files:
		#
		#  * Do not demultiplex, but
		#  * Create a log file with demultiplex statistics.
		#
		# Check if the files required for the read count check are present.
		#

		declare    label=${filenamePrefix}
		declare -a read_counts
		declare -i total_reads=0
		declare -i longest_read_count_length=5
		declare -i longest_barcode_length=7

		#
		# Read counts of the demultiplexed files.
		# Note: we actually count lines, which equals reads * 4 for FastQ files.
		#
		declare    barcodeD=${filenameSuffixDiscardedReads}
		declare    fastq=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}
		declare -i reads=-1
		_count_reads ${fastq} ${barcodeD} 'reads'
		read_counts=(${read_counts[@]-} ${barcodeD}:${reads})
		((total_reads+=reads))

		((n_elements=${#compressedDemultiplexedSampleFastqFilenameSR[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
			barcodeR=${barcode[fileToCheck]}
			fastq=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenameSR[fileToCheck]}
			declare -i reads=-1
			_count_reads ${fastq} ${barcodeR} 'reads'
			read_counts=(${read_counts[@]-} ${barcodeR}:${reads})
			((total_reads+=reads))
		done

		declare log=${fluxDir}/${label}.demultiplex.log
		_save_log ${longest_barcode_length} ${longest_read_count_length} 'Reads' ${total_reads} ${label} ${log} 'read_counts[@]'

	fi

elif [ "$seqType" == "PE" ]
then
	if [[ "${barcode[0]}" == "None" || "${barcode[0]}" == "" ]]
	then
		#
		# No barcodes used in this lane: Do nothing.
		#
		touch ${fluxDir}/${filenamePrefix}.demultiplex.read_count_check.skipped
	else
		#
		# Illumina-style demultiplexed files:
		#
		#  * Do not demultiplex, but
		#  * Perform a read count check between reads 1 and 2 and
		#  * Create a log file with demultiplex statistics.
		#
		# Check if the files required for the read count check are present.
		#

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
		declare    barcodeD=${filenameSuffixDiscardedReads}
		declare    fastq_1=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}
		declare    fastq_2=${runResultsDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}
		declare -i reads_1=-1
		declare -i reads_2=-2
		_count_reads ${fastq_1} ${barcodeD} 'reads_1'
		_count_reads ${fastq_2} ${barcodeD} 'reads_2'
		if (( $reads_1 != $reads_2)); then
			touch ${fluxDir}/${label}_${barcodeD}.read_count_check_for_pairs.FAILED
			echo "FATAL: Number of reads in both ${label}_${barcode} FastQ files not the same!"
			exit 1
		fi
		read_pair_counts=(${read_pair_counts[@]-} ${barcodeD}:${reads_1})
		((total_read_pairs+=reads_1))

		((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE1[@]}, max_index=n_elements - 1))
		for ((fileToCheck = 0; fileToCheck <= max_index; fileToCheck++))
		do
		barcodeR=${barcode[fileToCheck]}
		fastq_1=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE1[fileToCheck]}
		fastq_2=${runResultsDir}/${compressedDemultiplexedSampleFastqFilenamePE2[fileToCheck]}
		reads_1=-1
		reads_2=-2
		_count_reads ${fastq_1} ${barcodeR} 'reads_1'
		_count_reads ${fastq_2} ${barcodeR} 'reads_2'
		if (( $reads_1 != $reads_2)); then
			touch ${fluxDir}/${label}_${barcodeR}.read_count_check_for_pairs.FAILED
			echo "FATAL: Number of reads in both ${label}_${barcode} FastQ files not the same!"
			exit 1
		fi
		read_pair_counts=(${read_pair_counts[@]-} ${barcodeR}:${reads_1})
		((total_read_pairs+=reads_1))

		done

		declare log=${fluxDir}/${label}.demultiplex.log
		_save_log ${longest_barcode_length} ${longest_read_count_length} 'Read Pairs' ${total_read_pairs} ${label} ${log} 'read_pair_counts[@]'


		touch ${fluxDir}/${filenamePrefix}.read_count_check_for_pairs.passed

	fi

fi

mv ${fluxDir}/${filenamePrefix}* ${runResultsDir}
echo "moved ${fluxDir}/${filenamePrefix}* ${runResultsDir}"
