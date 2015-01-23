#MOLGENIS nodes=1 cores=1 mem=4G

#FOREACH project,chr

#Parameter mapping
#string project
#string chr
#string ImputeOutputFolder
#string ImputeOutputFolderTemp
#string knownHapsG
#string genotypeAlignerJar
#string vcf
#string refType
#string javaExecutable

echo "chr: ${chr}"
echo "ImputeOutputFolder: ${ImputeOutputFolder}"
echo "ImputeOutputFolderTemp: ${ImputeOutputFolderTemp}"
echo "knownHapsG: ${knownHapsG}"
echo "genotypeAlignerJar: ${genotypeAlignerJar}"
echo "vcf: ${vcf}"
echo "refType: ${refType}"
echo "javaExecutable: $(javaExecutable)"

haps_input=${knownHapsG}
sample_input="${knownHapsG%.haps}.sample"
basename_input="${knownHapsG%.haps}"
haps_output=${ImputeOutputFolder}/chr${chr}.haps
sample_output=${ImputeOutputFolder}/chr${chr}.sample

alloutputsexist \
	"${haps_output}" \
	"${sample_output}" 

mkdir -p ${ImputeOutputFolder}
mkdir -p ${ImputeOutputFolderTemp}

#Mark the start time
startTime=$(date +%s)

#Fetch files
getFile ${haps_input}
inputs ${haps_input}

getFile ${sample_input}
inputs ${sample_input}

#Do the alignment
if ${javaExecutable} -jar ${genotypeAlignerJar} \
	--input ${basename_input} \
	--inputType SHAPEIT2 \
	--ref ${vcf} \
	--refType ${refType} \
	--forceChr ${chr} \
	--output ${ImputeOutputFolderTemp}/~chr${chr} \
	--outputType SHAPEIT2
then
	cp ${ImputeOutputFolderTemp}/~chr${chr}.haps ${ImputeOutputFolder}/chr${chr}.haps
	cp ${ImputeOutputFolderTemp}/~chr${chr}.sample ${ImputeOutputFolder}/chr${chr}.sample
	cp ${ImputeOutputFolderTemp}/~chr${chr}.log ${ImputeOutputFolder}/chr${chr}.log

	putFile ${ImputeOutputFolder}/chr${chr}.haps
	putFile ${ImputeOutputFolder}/chr${chr}.sample
	putFile ${ImputeOutputFolder}/chr${chr}.log
else
	exit 1
fi

endTime=$(date +%s)


#Source: http://stackoverflow.com/questions/12199631/convert-seconds-to-hours-minutes-seconds-in-bash

num=$(($endTime-$startTime))
min=0
hour=0
day=0
if ((num>59));then
    sec=$(($num%60))
    num=$(($num/60))
    if ((num>59));then
        min=$(($num%60))
        num=$(($num/60))
        if ((num>23));then
            hour=$(($num%24))
            day=$(($num/24))
        else
            hour=${num}
        fi
    else
        min=${num}
    fi
else
    sec=${num}
fi
echo "Running time: ${day} days ${hour} hours ${min} mins ${sec} secs"


