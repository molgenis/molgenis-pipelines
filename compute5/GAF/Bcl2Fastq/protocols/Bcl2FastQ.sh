#
# =============================================================================
# BCL to FastQ conversion using Illumina's bcl2fastq convertor.
# =============================================================================
#

#
##
### parameters declaration.
##
#

#string umask
#string bcl2fastqVersion
#string bcl2fastqDir
#string scriptsDir
#string McWorksheet
#string run
#string bclDir
#string seqType
#string adapterMasking
#string truSeqAdapter1
#string truSeqAdapter2
#string adapterStringency

echo "umask: ${umask}"
echo "bcl2fastqVersion: ${bcl2fastqVersion}"
echo "bcl2fastqDir: ${bcl2fastqDir}"
echo "scriptsDir: ${scriptsDir}"
echo "McWorksheet: ${McWorksheet}"
echo "run: ${run}"
echo "bclDir: ${bclDir}"
echo "seqType: ${seqType}"
echo "adapterMasking: ${adapterMasking}"
echo "truSeqAdapter1: ${truSeqAdapter1}"
echo "truSeqAdapter2: ${truSeqAdapter2}"
echo "adapterStringency: ${adapterStringency}"

#
##
### Custom Functions.
##
#
declare -a stringArray

#
# Calculates per lane the number of mismatches between the barcodes. Results stored in mismatchArray. 
#
function CalculateMismatches() {

	eval mismatchArray=( $( 
	for i in "${!array[@]}"
	do
		for j in "${!array[@]}"
		do		 
			echo  "${array[$i]} ${array[$j]}"|\
			awk ' BEGIN {
			pos=0
			mismatches=0
			}
			{
			max=(length($1) >= length($2))? length($1): length($2)
			for(i=1; i <= max ; i++)
			{
				v1=substr($1, i, 1)
				v2=substr($2, i, 1)
				if(v1 != v2){
					pos=i
					mismatches=mismatches +1
				}
			}
			printf("%d\n", mismatches)
	}'
	done	
done
))
}

#
# Checks is the "value" is present in the given array.
#
function contains() {
	local n=$#
	local value=${!n}
	for ((i=1;i < $#;i++)) {
		if [ "${!i}" == "${value}" ]; then
			echo "y"
			return 0
		fi
	}
	echo "n"
	return 1
}

#
# Build an array with the number of allowed mismatches per lane.
#
function BuildMismatchstring() {
	if [ -z "${mismatchArray:-}" ]; then
		echo "--- mismatches unknown, 0 possible for Illumina demultiplexing."
		stringArray+=('0')
	else
		if [ $(contains "${mismatchArray[@]}" "1") == "y" ]; then
			echo "--- 0 mismatches possible for Illumina demultiplexen ---"
			stringArray+=('0')
	 	else
			echo "--- 1 mismatch possible for Illumina demultiplexing ---"
			stringArray+=('1')
		fi
	fi
}


#
##
### Main.
##
#


#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=12:00:00 nodes=1 cores=6 mem=12


#
# Change permissions.
#
umask ${umask}

#
# Setup environment for tools we need.
#
module load bcl2fastq/${bcl2fastqVersion}
module list

#
# Initialize script specific vars.
#
RESULTDIR=${bcl2fastqDir[0]}
SCRIPTNAME=${taskId}
FLUXDIR=${RESULTDIR}/${SCRIPTNAME}_in_flux/
fluxDir=${FLUXDIR}

#
# Should I stay or should I go?
#
if [ -f "${rundir}/${SCRIPTNAME}.sh.finished" ]
then
	# Skip this job script.
	echo "${rundir}/${SCRIPTNAME}.sh.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

#
# Create sample sheet in Illumina format based on our GAF sample sheets.
#
export PERL5LIB=${scriptsDir}/
perl ${scriptsDir}/CreateIlluminaSampleSheet.pl \
-i ${McWorksheet} \
-o ${fluxDir}/Illumina_R${run}.csv \
-r ${run}


#
# Select unique barcodes from the colomn barcode per lane from a worksheet.csv
#
# select unique present lanes 
eval Lanes=( $(
awk -v header="Lane" '
BEGIN { FS=","; c=0 }
NR == 1 { for (i=1;i<=NF;i++) { if ($i==header) { c=i }} }
NR > 1 && c>0 { print $c }
' ${fluxDir}/Illumina_R${run}.csv | sort | uniq
))
for i in "${Lanes[@]}"
	do

	echo "Calculate mismatches for lane $i:"
	unset array
	unset mismatchArray
	eval array=( $(
	awk -v lane=$i '{ 
		split($0,arr,","); 
		#Column Lane in Illumina_Rxxx.csv
		if(arr[2] ==lane) 
		print arr[5]
		}' ${fluxDir}/Illumina_R${run}.csv | sort | uniq 
	))
	
	# Call 2 functions per lane for calculating the number of mismatches possible and build the mismatch array.
	
	if [ -z "${array:-}" ] ; then
		declare -a array
		BuildMismatchstring
	else
		CalculateMismatches
		BuildMismatchstring
	fi
	
done


# Check if mismatchArray is set.
# If barcodes differ only at one position, Illumina demultiplexing is started with zero mismatches for that lane
# else, with one mismatch.
 
if [[ "${mismatchArray}" ]];then
	#
	# Build mismatches string for the Illumina tool.
	#
	for i in "${stringArray[@]}"
		do
		b+=$i","
	done
	
	echo "Mismatches string is: ${b:0:${#b}-1}"
		
	#
	# Set number of mismatches to 1 if not null.
	#
	if [ $(contains "${stringArray[@]}" "0") == "y" ]; then
		echo "---FATAL: 0 mismatches possible for Illumina demultiplexing. Adjust the worksheet. ---"
			mismatchNr=('0')
			exit 1
	else
			echo "--- 1 mismatches possible for Illumina demultiplexing ---"
			mismatchNr=('1')
	fi	
	#
	
# Configure BCL to FastQ conversion using Illumina tool possibly including demultiplexing with mismatches.
# Using adapter masking if possible	

	if [[ "$adapterMasking" == "ENABLED" ]]
	then
		if [[ "$seqType" == "PE" ]]
		then
				configureBclToFastq.pl \
				--force \
				--fastq-cluster-count 0 \
				--no-eamss \
				--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
				--output-dir ${fluxDir}/ \
				--sample-sheet ${fluxDir}/Illumina_R${run}.csv \
				--adapter-sequence ${truSeqAdapter1} \
				--adapter-sequence ${truSeqAdapter2} \
				--adapter-stringency ${adapterStringency} \
				--mismatches ${mismatchNr}
	
		elif [[ "$seqType" == "SR" ]]
		then
				configureBclToFastq.pl \
				--force \
				--fastq-cluster-count 0 \
				--no-eamss \
				--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
				--output-dir ${fluxDir}/ \
				--sample-sheet ${fluxDir}/Illumina_R${run}.csv \
				--adapter-sequence ${truSeqAdapter1} \				
				--adapter-stringency ${adapterStringency} \
				--mismatches ${mismatchNr}		
	else
		echo "FATAL: SeqType unknown."
		exit 1				
	fi
	
	elif [[ "$adapterMasking" == "DISABLED" ]]
	then
			configureBclToFastq.pl \
			--force \
			--fastq-cluster-count 0 \
			--no-eamss \
			--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
			--output-dir ${fluxDir}/ \
			--sample-sheet ${fluxDir}/Illumina_R${run}.csv \
			--mismatches ${mismatchNr}	
	else
		echo "FATAL: adapterMasking unknown. Not ENABLED or DISABLED. "
		exit 1
	fi	
	
else 
	echo "FATAL: mismatchArray is empty."
	exit 1
fi


#
# Convert the BCLs to FastQs.
#
cd ${fluxDir}/
make -j 6

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