#MOLGENIS walltime=5:59:00 mem=16gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string CHR
#string WORKDIR
#string projectDir
#string genotypedChrVcfGL
#string genotypedChrVcfGLDir
#string bcftoolVersion
#string genotypedChrVcfGLFilteredDir
#string genotypedChrVcfGLFiltered
#string genotypedChrVcfGLDir
#string tabixVersion
#string genotypedChrVcfBeagleGenotypeProbabilitiesFiltered
#string beagleFilteredDir

echo "## "$(date)" Start $0"

${stage} BCFtools/${bcftoolVersion}
${stage} tabix/${tabixVersion}
${checkStage}


mkdir -p ${genotypedChrVcfGLFilteredDir}

echo "zcat ${genotypedChrVcfGL} to intervals"
zcat ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered} | \
    grep -v '^#' |
    awk '{print $1 "\t" $2 }' > ${beagleFilteredDir}/all_positions_chr${CHR}.intervals

echo "zcat the old file to new file. Change name so that the old file does not get corrupted"
zcat ${genotypedChrVcfGL} > $TMPDIR/$(basename ${genotypedChrVcfGL%.gz})
echo "bgzip vcf file"

bgzip  $TMPDIR/$(basename ${genotypedChrVcfGL%.gz})
tabix  $TMPDIR/$(basename ${genotypedChrVcfGL})

echo "bcftools filter"
bcftools filter -R ${beagleFilteredDir}/all_positions_chr${CHR}.intervals \
    -o ${genotypedChrVcfGLFiltered%.gz} \
    -O v \
    $TMPDIR/$(basename ${genotypedChrVcfGL})

cd ${genotypedChrVcfGLFilteredDir}/
echo "gzip the output file"
gzip ${genotypedChrVcfGLFiltered%.gz}
md5sum $(basename ${genotypedChrVcfGLFiltered}) > ${genotypedChrVcfGLFiltered}.md5
cd -
echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "


