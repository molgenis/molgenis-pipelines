#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string gatkVersion
#string familyID
#string mergedFamilyVCF
#string mergedFamilyVCFdir
#list outputSampleDNAVCF,outputSampleRNAVCF,relation



#################################################################################
#########Function to retrieve indices from array, based on element value#########
#################################################################################
#The function takes two inputs, first is the array to search in, second the
#value to search for
get_index () {
	array=$1[@]
    value=$2
    my_array=("${!array}")
    for i in "${!my_array[@]}"; do
    	if [[ "${my_array[$i]}" = "${value}" ]]; then
        	echo "${i}";
        fi
    done
}
#################################################################################



echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${mergedFamilyVCFdir}


#Produce lists of VCFs
# Debugging purpose:
# DNAVCFs=($(printf '%s\n' "${outputSampleDNAVCF[@]}" | sort -u ))
#
DNAVCFs=($(printf '%s\n' "${outputSampleDNAVCF[@]}"))
RNAVCFs=($(printf '%s\n' "${outputSampleRNAVCF[@]}"))
relations=($(printf '%s\n' "${relation[@]}"))

#Final array which contains the VCFs to merge
VCFs=()

#Extract child DNA VCF from array by index
ChildDNAVCFidx=$(get_index relations "child")
ChildDNAVCF=${outputSampleDNAVCF["$ChildDNAVCFidx"]}
VCFs+=($ChildDNAVCF)

#Extract father RNA VCF from array by index
FatherRNAVCFidx=$(get_index relations "father")
FatherRNAVCF=${outputSampleRNAVCF["$FatherRNAVCFidx"]}
VCFs+=($FatherRNAVCF)

#Extract mother RNA VCF from array by index
MotherRNAVCFidx=$(get_index relations "mother")
MotherRNAVCF=${outputSampleRNAVCF["$MotherRNAVCFidx"]}
VCFs+=($MotherRNAVCF)

toMerge=$(printf ' --variant %s ' $(printf '%s\n' ${VCFs[@]}))

# Merge VCFs per family ID
java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
	-T CombineVariants \
	-R ${onekgGenomeFasta} \
	${toMerge} \
	-o ${mergedFamilyVCF} \
	-L ${CHR}


cd ${mergedFamilyVCFdir}/
md5sum $(basename ${mergedFamilyVCF}) > ${mergedFamilyVCF}.md5
md5sum $(basename ${mergedFamilyVCF}.tbi) > ${mergedFamilyVCF}.tbi.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "