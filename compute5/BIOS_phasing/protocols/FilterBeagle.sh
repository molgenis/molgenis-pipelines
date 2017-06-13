#MOLGENIS walltime=6-23:59:00 mem=34gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string gatkVersion

#string vcf
#string genotypedChrVcfTbi

#string CHR
#string genotypedChrVcfBeagleGenotypeProbabilities
#string tabixVersion
#string referenceFasta
#string beagleFilteredDir
#string genotypedChrVcfBeagleGenotypeProbabilitiesFiltered
#string DR2Filter

echo "## "$(date)" Start $0"


#Set logdir to return to after gzipping created files, otherwise *.env and *.finished file are not written to correct folder/directory
LOGDIR="$PWD"



${stage} GATK/${gatkVersion}
${stage} tabix/${tabixVersion}
${checkStage}

mkdir -p ${beagleFilteredDir}


java -Xmx8g -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
    -T SelectVariants \
    -R ${referenceFasta} \
    -V ${genotypedChrVcfBeagleGenotypeProbabilities}.vcf.gz \
    -o ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered} \
    -select "DR2 > ${DR2Filter}"


cd ${beagleDir}
echo "gunzipping.."
gunzip ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered}
echo "gzipping..."
gzip ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered%.gz}

cd ${beagleDir}
bname=$(basename ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered})
md5sum ${bname}.vcf.gz > ${bname}.vcf.gz.md5
cd -
echo "succes moving files";

#changedir to logdir
cd $LOGDIR

echo "## "$(date)" ##  $0 Done "

