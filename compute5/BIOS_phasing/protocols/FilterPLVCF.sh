#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

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

echo "## "$(date)" Start $0"

${stage} BCFtools/${bcftoolVersion}
${checkStage}


mkdir -p ${genotypedChrVcfGLFilteredDir}


zcat ${genotypedChrVcfGL} | \\
awk '{print \$1 \":\" \$2 \"-\" \$2 }' > ${genotypedChrVcfGLDir}/all_positions_chr${CHR}.intervals

bcftools filter -r ${genotypedChrVcfGLDir}/all_positions_chr${CHR}.intervals \
    -o ${genotypedChrVcfGLFiltered} \
    -O z \
    ${genotypedChrVcfGL}

cd ${genotypedChrVcfGLDir}/
md5sum $(basenem ${genotypedChrVcfGLFiltered}) > ${genotypedChrVcfGLFiltered}.md5
md5sum $(basenem ${genotypedChrVcfGLFiltered}.tbi) > ${genotypedChrVcfGLFiltered}.tbi.md5

echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "

