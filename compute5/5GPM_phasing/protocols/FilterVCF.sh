#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string gatkVersion
#string mergedFamilyVCF
#string filteredFamilyVCFdir
#string filteredFamilyVCF

echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${filteredFamilyVCFdir}


# Extract only bi-allelic sites for samples of interest from VCF
# Also only select sites where all samples have a genotype
# Do we still need to add other filtering options like GQ, DP, etc?
java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
-T SelectVariants \
-R ${onekgGenomeFasta} \
-V ${mergedFamilyVCF} \
-o ${filteredFamilyVCF} \
-selectType SNP \
-L ${CHR} \
--maxNOCALLfraction 0 \
-restrictAllelesTo BIALLELIC


cd ${filteredFamilyVCFdir}/
md5sum $(basename ${filteredFamilyVCF}) > ${filteredFamilyVCF}.md5
md5sum $(basename ${filteredFamilyVCF}.tbi) > ${filteredFamilyVCF}.tbi.md5
cd -
echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "

