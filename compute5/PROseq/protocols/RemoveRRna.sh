#MOLGENIS nodes=1 ppn=10 mem=8gb walltime=10:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string rRNAdustVersion
#string WORKDIR
#string projectDir
#string rRNAfilteredDir
#string reads1FqGz
#string reads2FqGz
#string rRNArefSeq

#getFile ${reads1FqGz}

${stage} rRNAdust/${rRNAdustVersion}
${checkStage}

echo "## "$(date)" ##  $0 Started "
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

mkdir -p ${rRNAfilteredDir}
echo ${rRNAfilteredDir}/${reads1FqGz##*/} 
if rRNAdust ${rRNArefSeq}  ${reads1FqGz} > ${rRNAfilteredDir}/${reads1FqGz##*/}
then
    if [ ${#reads2FqGz} -eq 1 ];
    then
        echo 'paired end'
        if rRNAdust ${rRNArefSeq}  ${reads2FqGz} > ${rRNAfilteredDir}/${reads2FqGz##*/}
        then
            echo "returncode: 0";
            echo "md5sums"
            echo "${rRNAfilteredDir}/${reads1FqGz##*/} - " md5sum ${rRNAfilteredDir}/${reads1FqGz##*/}
            echo "${rRNAfilteredDir}/${reads2FqGz##*/} - " md5sum ${rRNAfilteredDir}/${reads2FqGz##*/}
            #putFile ${rRNAfilteredDir}/${reads1FqGz##*/}
            #putFile ${rRNAfilteredDir}/${reads2FqGz##*/}
            echo "succes moving files";
        else
            echo "returncode: $?";
            echo "fail";
        fi
    else
        echo "returncode: 0";
        echo ${rRNAfilteredDir}/${reads1FqGz##*/}
        echo "md5sums"
        echo "${rRNAfilteredDir}/${reads1FqGz##*/} - " md5sum ${rRNAfilteredDir}/${reads1FqGz##*/}
        #putFile ${rRNAfilteredDir}/${reads1FqGz##*/}
        echo "succes moving files";
    fi
else
    echo "returncode: $?";
    echo "fail";
fi

echo "## "$(date)" ##  $0 Done "