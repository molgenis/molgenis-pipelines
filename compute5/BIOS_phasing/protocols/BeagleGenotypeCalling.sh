#MOLGENIS walltime=6-23:59:00 mem=34gb nodes=1 ppn=2

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
#string tabixVersion

echo "## "$(date)" Start $0"


#Set logdir to return to after gzipping created files, otherwise *.env and *.finished file are not written to correct folder/directory
LOGDIR="$PWD"



${stage} beagle/${beagleVersion}
${stage} tabix/${tabixVersion}
${checkStage}

mkdir -p ${beagleDir}

java -Xmx32g -Djava.io.tmpdir=$TMPDIR -XX:ParallelGCThreads=2 -jar $EBROOTBEAGLE/beagle.${beagleJarVersion}.jar \
 gl=${vcf} \
 out=${genotypedChrVcfBeagleGenotypeProbabilities} \
 chrom=${CHR}
 
 #Decompress the beagle gzipped output and gzip it again. There's a bug on some platforms which causes incompatibility between normal zlib and boost zlib.
 #This also affects our system! More information here: https://mat.gen.gz.stats.ox.ac.uk.gen.gzetics_software/.hap.gzeit/.hap.gzeit.html#gcall
 
cd ${beagleDir}

#### below commented code moved to after BeagleFilter, kept in as reminder of stupid gzipping
#echo "gunzipping.."
#gunzip ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz
#echo "gzipping..."
#gzip ${beagleDir}/${project}.chr${CHR}.beagle.genotype.probs.gg.vcf

cd ${beagleDir}
bname=$(basename ${genotypedChrVcfBeagleGenotypeProbabilities})
md5sum ${bname}.vcf.gz > ${bname}.vcf.gz.md5
cd -
echo "succes moving files";

#changedir to logdir
cd $LOGDIR

echo "## "$(date)" ##  $0 Done "

