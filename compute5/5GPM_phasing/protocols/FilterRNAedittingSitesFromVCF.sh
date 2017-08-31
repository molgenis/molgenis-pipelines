#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string bedtoolsVersion
#string htslibVersion
#string mergedFamilyVCF
#string filteredFamilyVCFdir
#string filteredFamilyVCF
#string filteredRNAsitesFamilyVCF
#string filteredRNAsitesFamilyVCFgz
#string rnaEditBed

echo "## "$(date)" Start $0"


${stage} BEDTools/${bedtoolsVersion}
${stage} HTSlib/${htslibVersion}
${checkStage}


mkdir -p ${filteredFamilyVCFdir}


#Use bedtools to remove overlapping RNA-editting sites from VCF file, this results in unsorted file
bedtools \
intersect \
-v \
-a ${filteredFamilyVCF} \
-b ${rnaEditBed} \
-wa >> ${filteredRNAsitesFamilyVCF}.tmp.txt

#Sort *.tmp.txt file by chromosome and position
sort -k1n -k2n ${filteredRNAsitesFamilyVCF}.tmp.txt > ${filteredRNAsitesFamilyVCF}.tmp.sorted.txt

#Extract header from input VCF file
zcat ${filteredFamilyVCF} | head -2000 | grep '^#' > ${filteredRNAsitesFamilyVCF}.header.txt

#Cat header and sorted file together into single file
cat ${filteredRNAsitesFamilyVCF}.header.txt ${filteredRNAsitesFamilyVCF}.tmp.sorted.txt > ${filteredRNAsitesFamilyVCF}

#Remove all tmp data
rm ${filteredRNAsitesFamilyVCF}.tmp.txt
rm ${filteredRNAsitesFamilyVCF}.tmp.sorted.txt
rm ${filteredRNAsitesFamilyVCF}.header.txt


echo "returncode: $?";
cd ${filteredFamilyVCFdir}
bgzip ${filteredRNAsitesFamilyVCF}
tabix ${filteredRNAsitesFamilyVCFgz}
echo "making md5sum..."
md5sum $(basename ${filteredRNAsitesFamilyVCFgz}) > ${filteredRNAsitesFamilyVCFgz}.md5
md5sum $(basename ${filteredRNAsitesFamilyVCFgz}.tbi) > ${filteredRNAsitesFamilyVCFgz}.tbi.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "

