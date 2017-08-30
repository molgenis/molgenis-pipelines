#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=1

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string shapeitVersion
#string phasedFamilyOutputPrefix
#string CHR
#string htslibVersion


echo "## "$(date)" Start $0"


${stage} shapeit/${shapeitVersion}
${stage} HTSlib/${htslibVersion}
${checkStage}


#Run shapeit convert
shapeit \
-convert \
--input-haps ${phasedFamilyOutputPrefix} \
--output-vcf ${phasedFamilyOutputPrefix}.vcf.gz

echo "returncode: $?";
cd ${phasedFamilyOutputDir}
bname=$(basename ${phasedFamilyOutputPrefix}.vcf.gz)
# has to be bgzipped
gunzip ${bname}
bgzip ${bname%.gz}
tabix ${bname}
echo "making md5sum..."
md5sum ${bname} > ${bname}.md5
cd -
echo "succes moving files";


echo "## "$(date)" ##  $0 Done "