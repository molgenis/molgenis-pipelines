#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string gatkVersion
#string excludeIntervallist
#string filteredFamilyVCFdir
#string filteredFamilyVCF
#string filteredRNAsitesFamilyVCFgz


echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}


mkdir -p ${filteredFamilyVCFdir}


#Use GATK to remove variants overlapping with RNA-editting sites
java -Xmx8g -Djava.io.tmpdir=\${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
    -T SelectVariants \
    -R ${onekgGenomeFasta} \
    -V ${filteredFamilyVCF} \
    -o ${filteredRNAsitesFamilyVCFgz} \
    --excludeIntervals ${excludeIntervallist}


echo "returncode: $?";
cd ${filteredFamilyVCFdir}
echo "making md5sum..."
md5sum $(basename ${filteredRNAsitesFamilyVCFgz}) > ${filteredRNAsitesFamilyVCFgz}.md5
md5sum $(basename ${filteredRNAsitesFamilyVCFgz}.tbi) > ${filteredRNAsitesFamilyVCFgz}.tbi.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "

