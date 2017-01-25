#MOLGENIS walltime=23:00:00 mem=15gb ppn=2

### variables to help adding to database (have to use weave)
#string project
#string sampleName
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string bam
#string ASReadsDirSample
#string projectDir
#string ASReadsDir
#string ASReadsPrefix
#string couplingFile
#string AseVersion
#list CHR
echo "## "$(date)" Start $0"


#Load gatk module
${stage} CS-ASE/${AseVersion}
${checkStage}

mkdir -p ${ASReadsDir}
mkdir -p ${ASReadsDirSample}
for chromosome in ${CHR[@]}
do
    echo "Starting chromsome $chromosome"
    trityperDir=${projectDir}/trityper_chr${chromosome}
    if java -XX:ParallelGCThreads=2 -jar ${EBROOTCSMINASE}/cellTypeSpecificAlleleSpecificExpression-${AseVersion%-Java*}-jar-with-dependencies.jar \
        --action 1 \
        --output ${ASReadsPrefix}_chr${chromosome}.txt \
        --coupling_file ${couplingFile} \
        --genotype_location ${trityperDir} \
        --bam_file ${bam}
    then
        echo "returncode: $?";
        echo "succes chr${chromosome}";
    else
        echo "returncode: $?";
        echo "fail chr${chromosome}";
    fi
done
echo "## "$(date)" ##  $0 Done "
