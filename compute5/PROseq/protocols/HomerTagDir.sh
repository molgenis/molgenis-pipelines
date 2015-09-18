#MOLGENIS walltime=23:59:00 mem=12gb ppn=8

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string bsqrBam
#string homerTagDir
#string toolDir
#string homerLocation
#string weblogoVersion
#string samtoolsVersion
#string bedgraphBigwigLocation
#string homerSampleTagDir

echo "## "$(date)" Start $0"
echo "ID (project-sampleName): ${project}-${sampleName}"
mkdir -p ${homerTagDir}

# bad! But Homer is near impossible to install with easybuild so can't use module load
PATH=$PATH:${homerLocation}
PATH=$PATH:${bedgraphBigwigLocation}


#Load gatk module
${stage} SAMtools/${samtoolsVersion}
${stage} Weblogo/${weblogoVersion}
${checkStage}

if makeTagDirectory ${homerSampleTagDir} ${bsqrBam}
then
 echo "returncode: $?"; 
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
