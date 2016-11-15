#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string shapeitVersion
#string shapeitLigatedHaplotype

echo "## "$(date)" Start $0"


getFile ${shapeitLigatedHaplotype}


${stage} shapeit/${shapeitVersion}
${checkStage}

#Copy original haps files to tmp to do conversion needed as input for shapeit convert
gunzip -c ${shapeitPhasedOutputPrefix}.haps.gz > ${shapeitPhasedOutputPrefix}.haps
cp ${shapeitPhasedOutputPrefix}.haps.sample ${shapeitPhasedOutputPrefix}.sample

#Run shapeit convert

if shapeit \
    -convert \
    --input-haps ${shapeitLigatedHaplotype} \
    --output-vcf ${shapeitPhasedOutputPrefix}.vcf.gz
then
 echo "returncode: $?";
 putFile ${shapeitPhasedOutputPrefix}.vcf.gz
 cd ${shapeitDir}
 bname=$(basename ${shapeitPhasedOutputPrefix}.vcf.gz)
 md5sum ${bname} > ${bname}.md5
 rm ${shapeitPhasedOutputPrefix}.haps
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "## "$(date)" ##  $0 Done "
