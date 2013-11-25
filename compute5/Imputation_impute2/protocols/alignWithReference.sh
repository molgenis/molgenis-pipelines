#MOLGENIS nodes=1 cores=1 mem=4G

#FOREACH project,chr

#Parameter mapping
#string project
#string chr
#string outputFolder
#string knownHapsG
#string genotypeAlignerJar
#string vcf

echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "knownHapsG: ${knownHapsG}"
echo "genotypeAlignerJar: ${genotypeAlignerJar}"
echo "vcf: ${vcf}"

haps_input=${knownHapsG}
sample_input="${knownHapsG%.haps}.sample"
basename_input="${knownHapsG%.haps}"
haps_output=${outputFolder}/chr${chr}.haps
sample_output=${outputFolder}/chr${chr}.sample

alloutputsexist \
	"${haps_output}" \
	"${sample_output}" 

mkdir -p ${outputFolder}

#Mark the start time
startTime=$(date +%s)

#Fetch files
getFile ${haps_input}
inputs ${haps_input}

getFile ${sample_input}
inputs ${sample_input}

#Do the alignment
if java -jar ${genotypeAlignerJar} \
	--input ${basename_input} \
	--inputType SHAPEIT2 \
	--ref ${vcf} \
	--refType VCF \
	--forceChr ${chr} \
	--output ${outputFolder}/~chr${chr} \
	--outputType SHAPEIT2
then
	mv ${outputFolder}/~chr${chr}.haps ${outputFolder}/chr${chr}.haps
	mv ${outputFolder}/~chr${chr}.sample ${outputFolder}/chr${chr}.sample
	mv ${outputFolder}/~chr${chr}.log ${outputFolder}/chr${chr}.log

	putFile ${outputFolder}/chr${chr}.haps
	putFile ${outputFolder}/chr${chr}.sample
	putFile ${outputFolder}/chr${chr}.log
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
            hour=num
        fi
    else
        min=num
    fi
else
    sec=num
fi
echo "Running time: ${day} days ${hour} hours ${min} mins ${sec} secs"





