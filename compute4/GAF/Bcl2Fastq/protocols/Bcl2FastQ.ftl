#MOLGENIS
#FOREACH flowcell

#
# =============================================================================
# BCL to FastQ conversion using Illumina's bcl2fastq convertor.
# =============================================================================
#

#
##
### Custom Functions.
##
#
<#noparse>
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
		echo "--- mismatches unknown, 1 possible for GAF barcode demultiplexing."
		stringArray+=('1')
	else
		if [ $(contains "${mismatchArray[@]}" "1") == "y" ] || [ $(contains "${mismatchArray[@]}" "2") == "y" ]; then
			echo "--- 0 mismatches possible for Illumina demultiplexen ---"
			stringArray+=('0')
		else
			echo "--- 1 mismatch possible for Illumina demultiplexing ---"
			stringArray+=('1')
		fi
	fi
}

</#noparse>

#
##
### Main.
##
#


#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=12:00:00 nodes=1 cores=6 mem=12
#FOREACH run

#
# Bash sanity.
#
set -e
set -u

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
RESULTDIR=<#if bcl2fastqDir?is_enumerable>${bcl2fastqDir[0]}<#else>${bcl2fastqDir}</#if>
SCRIPTNAME=${jobname}
FLUXDIR=<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>_in_flux/
<#assign fluxDir>${r"${FLUXDIR}"}</#assign>

#
# Should I stay or should I go?
#
if [ -f "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished" ]
then
    # Skip this job script.
	echo "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished already exists: skipping this job."
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
<#noparse>	
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
		</#noparse>
		}' ${fluxDir}/Illumina_R${run}.csv | sort | uniq 
	))
	
	# Call 2 functions per lane for calculating the number of mismatches possible and build the mismatch array.
	
	<#noparse>if [ -z "${array:-}" ]; then</#noparse>
		declare -a array
		declare -a mismatchArray
		BuildMismatchstring
	else
		CalculateMismatches
		BuildMismatchstring
	fi
	
done

<#noparse>

# Check if mismatchArray is set.
# If barcodes differ only at one position, Illumina demultiplexing is started with zero mismatches for that lane
# else, with one mismatch.
 
if [[ "${stringArray}" ]]; then
	#
	# Build mismatches string for the Illumina tool.
	#
	for i in "${stringArray[@]}"
		do
		 b+=$i","
	done
	
	echo "Maximum mismatches per lane are: ${b:0:${#b}-1}"
	
	
	#
	# Set number of mismatches to 1 if not null.
	#
	if [ $(contains "${stringArray[@]}" "0") == "y" ]; then
		echo "---FATAL: 0 mismatches possible for Illumina demultiplexing. Adjust the worksheet. ---"
		mismatchNr=('0')
		exit 1
	else
		echo "--- 1 mismatches possible for Illumina demultiplexen ---"
		mismatchNr=('1')
	fi
</#noparse>
	#
	# Configure BCL to FastQ conversion using Illumina tool possibly including demultiplexing with mismatches.
	#
	configureBclToFastq.pl \
	--force \
	--fastq-cluster-count 0 \
	--no-eamss \
	--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
	--output-dir ${fluxDir}/ \
	--sample-sheet ${fluxDir}/Illumina_R${run}.csv \<#if adapterTrimming == "ENABLED">
	--adapter-sequence ${truSeqAdapter1} \<#if seqType == "PE">
	--adapter-sequence ${truSeqAdapter2} \</#if>
	--adapter-stringency ${adapterStringency} \</#if>
	<#noparse>--mismatches ${mismatchNr}</#noparse>   
	
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
mv ${fluxDir}/* <#noparse>${RESULTDIR}/</#noparse>
rmdir ${fluxDir}
sync
touch <#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished
sync
