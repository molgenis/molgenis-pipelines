#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string beagleDir

#string beagleVersion

#list vcf
#string genotypedChrVcfTbi

#string genotypedChrVcfBeagleGenotypeProbabilities
#string chromosome
#string beagleJarVersion

echo "## "$(date)" Start $0"


getFile ${vcf}
getFile ${genotypedChrVcfTbi}


${stage} beagle/${beagleVersion}
${checkStage}

mkdir -p ${beagleDir}

if java -Xmx6g -XX:ParallelGCThreads=2 -jar $EBROOTBEAGLE/beagle.${beagleJarVersion}.jar \
 gl=${vcf} \
 out=${genotypedChrVcfBeagleGenotypeProbabilities} \
 chrom=${chromosome}
then
 echo "returncode: $?";
 putFile ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz
 cd ${beagleDir}
 bname=$(basename ${genotypedChrVcfBeagleGenotypeProbabilities})
 md5sum ${bname}.vcf.gz > ${bname}.vcf.gz.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

