#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string genotypedChrVcfGLDir
#string genotypedChrVcfGL
#string vcf
#string biopythonVersion
#string genotypedChrVcfGL
#string ngsutilsVersion
#string tabixVersion

echo "## "$(date)" Start $0"


${stage} Biopython/${biopythonVersion}
${stage} ngs-utils/${ngsutilsVersion}
${stage} tabix/${tabixVersion}
${checkStage}

mkdir -p ${genotypedChrVcfGLDir}

echo "Starting conversion."


#Run conversion script beagle vcf to .hap.gzeit format
if python $EBROOTNGSMINUTILS/PL_to_GL_reorder.py \
    --vcf ${vcf} \
    --out ${genotypedChrVcfGL}

then
 echo "returncode: $?";
 echo "unzipping and re-bgzipping"
 gunzip ${genotypedChrVcfGL};
 bgzip ${genotypedChrVcfGL%.gz};
 cd ${genotypedChrVcfGLDir}
 bname=$(basename ${genotypedChrVcfGL})
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 >&2 echo "went wrong with following command:"
 >&2 echo "python $EBROOTNGSMINUTILS/PL_to_GL_reorder.py \\
            --vcf ${vcf} \\
            --out ${genotypedChrVcfGL}"
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "Finished conversion."

echo "## "$(date)" ##  $0 Done "

