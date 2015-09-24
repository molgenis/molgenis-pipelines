#MOLGENIS walltime=23:59:00 mem=2gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string mergeSamFilesJar
#string mergedBam
#string mergedBamIdx
#string tempDir
#list inputMergeBam
#list inputMergeBamIdx
#string tmpDataDir
#string project
#string intermediateDir
#string indexFile


#expected to have one big vcf file with all samples and chromosomes merged
if [ $GCC_Analysis == "trio" ]
then
	java -Xmx2g -jar ${EBROOTGATK}/${gatkJar} \
	-R ${indexFile} \
	-T PhaseByTransmission \
	-V input.vcf \
	-ped input.ped \
	-o output.vcf
else
	echo "trio analysis skipped"
fi


