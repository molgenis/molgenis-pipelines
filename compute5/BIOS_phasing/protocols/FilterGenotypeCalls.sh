#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=5:59:59

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string vcf
#string callRateFilteredVCFDir
#string callRateFilteredVCF
#string callRateFilteredPASSonlyVCF
#string callRateFilteredPASSonlyVCFgz
#string genotypeQuality
#string callRate
#string CHR
#string ngsutilsVersion
#string tabixVersion



echo "## "$(date)" Start $0"


mkdir -p ${callRateFilteredVCFDir}

#Load NGS-utils module
${stage} ngs-utils/${ngsutilsVersion}
${stage} tabix/${tabixVersion}
${checkStage}


#Run filter script (This puts the value PASS in the VCF, so also filter on this one afterwards)
perl ${EBROOTNGSMINUTILS}/filterRNAseqCallsV2.pl \
--inputFile	${vcf} \
--outputFile ${callRateFilteredVCF} \
--genotypeQuality ${genotypeQuality} \
--callRate ${callRate} \
--removeNoGT

echo "returncode: $?";

#Bgzip VCF file and index
cd ${callRateFilteredVCFDir}
bname=$(basename ${callRateFilteredVCF})
# has to be bgzipped
bgzip ${bname}
tabix ${bname}.gz
echo "making md5sum..."
md5sum ${bname}.gz > ${bname}.gz.md5
md5sum ${bname}.gz.tbi > ${bname}.gz.tbi.md5
cd -
echo "succes moving files";



#Do additional filtering on FILTER column in VCF file and only select variants which are "PASS". These PASS only variants are used in downstream analysis.
echo "Selecting PASS only variants from VCF file.."

zcat ${callRateFilteredVCF}.gz | head -4000 | grep '^#' > ${callRateFilteredPASSonlyVCF}
zcat ${callRateFilteredVCF}.gz | grep -v '^#' | awk '{ if ($7 == "PASS") print $0 }' >> ${callRateFilteredPASSonlyVCF}

echo "returncode: $?";

#Bgzip VCF file and index
cd ${callRateFilteredVCFDir}
bname=$(basename ${callRateFilteredPASSonlyVCF})
# has to be bgzipped
bgzip ${bname}
tabix ${bname}.gz
echo "making md5sum..."
md5sum ${bname}.gz > ${bname}.gz.md5
md5sum ${bname}.gz.tbi > ${bname}.gz.tbi.md5
cd -
echo "succes moving files";



echo "## "$(date)" ##  $0 Done "





