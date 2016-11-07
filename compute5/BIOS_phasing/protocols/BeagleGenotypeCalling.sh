#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string beagleDir

#string beagleVersion

#string vcf
#string genotypedChrVcfTbi

#string genotypedChrVcfBeagleGenotypeProbabilities
#string CHR
#string beagleJarVersion

echo "## "$(date)" Start $0"


#Set logdir to return to after gzipping created files, otherwise *.env and *.finished file are not written to correct folder/directory
LOGDIR="$PWD"

getFile ${vcf}


${stage} beagle/${beagleVersion}
${checkStage}

mkdir -p ${beagleDir}

if java -Xmx6g -Djava.io.tmpdir=$TMPDIR -XX:ParallelGCThreads=2 -jar $EBROOTBEAGLE/beagle.${beagleJarVersion}.jar \
 gl=${vcf} \
 out=${genotypedChrVcfBeagleGenotypeProbabilities} \
 chrom=${CHR}
 
 #Decompress the beagle gzipped output and gzip it again. There's a bug on some platforms which causes incompatibility between normal zlib and boost zlib.
 #This also affects our system! More information here: https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.html#gcall
 
 cd ${beagleDir}
 gunzip ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz
 gzip ${beagleDir}/${project}.chr${CHR}.beagle.genotype.probs.gg.vcf
 
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
 exit 1;
fi

#changedir to logdir
cd $LOGDIR

echo "## "$(date)" ##  $0 Done "

