#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string.gen.gzotypedChrVcfGLDir
#string.gen.gzotypedChrVcfGL
#string vcf
#string biopythonVersion
#string.gen.gzotypedChrVcfGL
#string ngsutilsVersion

echo "## "$(date)" Start $0"

getFile ${vcf}

${stage} Biopython/${biopythonVersion}
${stage} ngs-utils/${ngsutilsVersion}
${checkStage}

mkdir -p $.gen.gzotypedChrVcfGLDir}

echo "Starting conversion."


#Run conversion script beagle vcf to .hap.gzeit format
if python $EBROOTNGSMINUTILS/PL_to_GL_reorder.py \
    --vcf ${vcf} \
    --out $.gen.gzotypedChrVcfGL}

then
 echo "returncode: $?";
 putFile $.gen.gzotypedChrVcfGL}
 cd $.gen.gzotypedChrVcfGLDir}
 bname=$(basename $.gen.gzotypedChrVcfGL})
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 >&2 echo "went wrong with following command:"
 >&2 echo "python $EBROOTNGSMINUTILS/PL_to_GL_reorder.py \\
            --vcf ${vcf} \\
            --out $.gen.gzotypedChrVcfGL}"
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "Finished conversion."

echo "## "$(date)" ##  $0 Done "

