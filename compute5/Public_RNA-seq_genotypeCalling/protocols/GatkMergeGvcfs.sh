#MOLGENIS walltime=14-23:59:59 mem=32gb ppn=8
################################^advised 45 gb for 300 files so 30 for 200 files?

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string onekgGenomeFasta
#string gatkVersion
#string haplotyperTargets
#string chromosome
#list haplotyperChrGvcf

#string haplotyperDir
#string mergeChrGvcf
#string mergeChrGvcfIdx
#string toolDir

echo "## "$(date)" Start $0"


#Load gatk module
${stage} GATK/${gatkVersion}
${checkStage}

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
gvcfs=($(printf '%s\n' "${haplotyperChrGvcf[@]}" | sort -u ))

inputs=$(printf ' --variant %s ' $(printf '%s\n' ${gvcfs[@]}))

mkdir -p ${haplotyperDir}

#pseudo: java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R ref.fasta -I input.bam -recoverDanglingHeads -dontUseSoftClippedBases -stand_call_conf 20.0 -stand_emit_conf 20.0 -o output.vcf from http://gatkforums.broadinstitute.org/discussion/3891/calling-variants-in-rnaseq

java -Xmx30g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGATK/GenomeAnalysisTK.jar \
 -T CombineGVCFs \
 -R ${onekgGenomeFasta} \
 -o ${mergeChrGvcf} \
 -L ${haplotyperTargets} \
 $inputs 

echo "returncode: $?"; 

cd ${haplotyperDir}
md5sum $(basename ${mergeGvcf})> $(basename ${mergeGvcf}).md5
cd -

echo "## "$(date)" ##  $0 Done "
