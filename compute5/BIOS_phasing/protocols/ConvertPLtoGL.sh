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

echo "## "$(date)" Start $0"

getFile ${vcf}

${stage} Biopython/${biopythonVersion}
${stage} ngs-utils/${ngsutilsVersion}
${checkStage}

mkdir -p ${genotypedChrVcfGLDir}

echo "Starting conversion."

#Gzip VCF because python script assumes gzipped input file
cp ${vcf} ${vcf}.tmp.vcf
gzip ${vcf}.tmp.vcf

#Run conversion script beagle vcf to shapeit format
if python $EBROOTNGSMINUTILS/PL_to_GL_reorder.py \
    --vcf ${vcf}.tmp.vcf.gz \
    --out ${genotypedChrVcfGL}

then
 echo "returncode: $?";
 putFile ${genotypedChrVcfGL}
 cd ${genotypedChrVcfGLDir}
 bname=$(basename ${genotypedChrVcfGL})
 md5sum ${bname} > ${bname}.md5
 cd -
 rm ${vcf}.tmp.vcf.gz
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "Finished conversion."

echo "## "$(date)" ##  $0 Done "

