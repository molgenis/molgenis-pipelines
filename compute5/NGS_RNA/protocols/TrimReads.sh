#MOLGENIS nodes=1 ppn=1 mem=2gb walltime=05:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"

#Load module
#module load cutadapt/1.8.1-goolf-1.7.20-Python-2.7.9
module load BBMap/35.69-Java-1.7.0_80
module list


#If paired-end do cutadapt for both ends, else only for one
if [ ${seqType} == "PE" ]
then

#	cutadapt --format=fastq \
#        --cut=12 \
#        -o ${peEnd1BarcodeFqGz}.tmp \
#	-p ${peEnd2BarcodeFqGz}.tmp \
#	${peEnd1BarcodeFqGz} ${peEnd2BarcodeFqGz}


	${EBROOTBBMAP}/bbduk.sh -Xmx1g \
	in1=${peEnd1BarcodeFqGz} \
	in2=${peEnd2BarcodeFqGz} \
	out1=${peEnd1BarcodeFqGz}.tmp \
	out2=${peEnd2BarcodeFqGz}.tmp \
	ref=${EBROOTBBMAP}/resources/polyA.fa.gz,${EBROOTBBMAP}/resources/truseq.fa.gz,${EBROOTBBMAP}/resources/polyG.fa.gz \
	overwrite=true \
	k=13 ktrim=r \
	useshortkmers=t \
	mink=5 \
	qtrim=t \
	trimq=10 \
	minlength=20

	gzip -c ${peEnd1BarcodeFqGz}.tmp > ${peEnd1BarcodeFqGz}
	gzip -c ${peEnd2BarcodeFqGz}.tmp > ${peEnd2BarcodeFqGz}

	echo -e "\nBBMap bbduk.sh finished succesfull. Moving temp files to final.\n\n"

elif [ ${seqType} == "SR" ]
then
#	cutadapt --format=fastq \
#	--cut=12 \
#	-o ${srBarcodeFqGz}.tmp \
#	${srBarcodeFqGz}

	${EBROOTBBMAP}/bbduk.sh -Xmx1g \
	in=${srBarcodeFqGz} \
	out=${srBarcodeFqGz}.tmp \
	ref=${EBROOTBBMAP}/resources/polyA.fa.gz,${EBROOTBBMAP}/resources/truseq.fa.gz,${EBROOTBBMAP}/resources/polyG.fa.gz \
	overwrite=true \
	k=13 \
	ktrim=r \
	useshortkmers=t \
	mink=5 \
	qtrim=t \
	trimq=10 \
	minlength=20

	gzip -c  ${srBarcodeFqGz}.tmp > ${srBarcodeFqGz}

	echo -e "\ncutadapt finished succesfull. Moving temp files to final.\n\n"
fi
