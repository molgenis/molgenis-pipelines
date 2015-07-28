#MOLGENIS walltime=23:59:00 mem=4gb

#string project
#list realignedBam

module load delly/v0.6.7

delly -t DEL -x human.hg19.excl.tsv -o ${project}.delly.vcf -g ${indexFile} ${realignedBam[@]}


