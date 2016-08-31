#MOLGENIS walltime=3-23:59:00 mem=30gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string bam
#string VCFprefix
#string VCFsuffix
#list CHR



#string bedtoolsVersion
#string samtoolsVersion
#string tabixVersion
#string RASQUALDIR
#string ASCountsDir
#string ASCountsDir
#string ASCountFilePostfix

echo "## "$(date)" Start $0"
getFile ${bam}

${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}

mkdir -p ${ASCountsDir}
echo Generating ASreads
export RASQUALDIR # rasqual must be declared and exported. Other scripts are in rasqualdir... what happens here

TMP=`mktemp`

# count AS reads
for chromosome in ${CHR[@]}
do
    echo chromosome $chromosome
    VCF=${VCFprefix}${chromosome}${VCFsuffix}
    ASCountFile=${ASCountsDir}/chr${chromosome}_${ASCountFilePostfix}
    if [ -f ${ASCountFile} ]; then
        echo "Removing old ASCountfile ${ASCountFile}"
        rm ${ASCountFile}
    fi
    START=`zcat ${VCF} | grep '#CHROM' -A 1 | tail -n 1 | cut -f 2`
    END=`zcat ${VCF} | tail -n 1 | cut -f 2`
    echo ${chromosome}:$START-$END

    tabix ${VCF} ${chromosome}: | cut -f 1-9 | gzip > $TMPDIR/temporalis.gz
    samtools view -F 0x0100 ${bam} ${chromosome}:$START-$END | \
			awk -v RASQUALDIR=${RASQUALDIR} '$7=="="{cmd = RASQUALDIR"/src/ASVCF/parseCigar "$6; cmd | getline N; print $3"\t"$4"\t"$4+N-1"\t"$6"\t"$10; close(cmd);}' | \
			${RASQUALDIR}/src/ASVCF/countAS $TMPDIR/temporalis.gz | \
			awk '{print $5","$6}' | gzip >> ${ASCountFile}
    rm $TMPDIR/temporalis.gz
    putFile ${ASCountFile}
done
echo "## "$(date)" $0 Done"
