#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string gatkVersion
#string inputVCF
#string outputVCF
#string outputVCFdir
#string sampleName
#string sample



echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${outputVCFdir}

# Check if sample is not "none", if it is no data is available and no conversion analysis should be executed
if [ "${sample}" != "none" ]
then

	# Extract only bi-allelic sites for samples of interest from VCF
	java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
		-T SelectVariants \
		-R ${onekgGenomeFasta} \
		-V ${inputVCF} \
		-o ${outputVCF} \
		-sn ${sample} \
		-selectType SNP \
		-L ${CHR} \
		-restrictAllelesTo BIALLELIC

	cd ${outputVCFdir}/
	md5sum $(basename ${outputVCF}) > ${outputVCF}.md5
	md5sum $(basename ${outputVCF}.tbi) > ${outputVCF}.tbi.md5
	cd -

else
	
	echo "Detected value \"none\" for sample ${sample}, meaning no data is present. Skipping further analysis!"
	
fi


echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "

