#MOLGENIS nodes=1 ppn=4 mem=4gb walltime=05:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string BBMapVersion
#string project
#string groupname
#string tmpName

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"

#Load module
module load ${BBMapVersion}
module list


#If paired-end do cutadapt for both ends, else only for one
if [ ${seqType} == "PE" ]
then

	${EBROOTBBMAP}/bbduk.sh -Xmx3g \
	in1=${peEnd1BarcodeFqGz} \
	in2=${peEnd2BarcodeFqGz} \
	out1=${peEnd1BarcodeFqGz}.tmp \
	out2=${peEnd2BarcodeFqGz}.tmp \
	ref=${EBROOTBBMAP}/resources/polyA.fa.gz,${EBROOTBBMAP}/resources/truseq.fa.gz,${EBROOTBBMAP}/resources/polyG.fa.gz \
	overwrite=true \
        k=13 \
	ktrim=l \
        qtrim=rl \
        trimq=14 \
        minlength=20 \
        forcetrimleft=11

	gzip ${peEnd1BarcodeFqGz}.tmp
	gzip ${peEnd2BarcodeFqGz}.tmp
	mv ${peEnd1BarcodeFqGz}.tmp.gz ${peEnd1BarcodeFqGz}
	mv ${peEnd2BarcodeFqGz}.tmp.gz ${peEnd2BarcodeFqGz}

	echo -e "\nBBMap bbduk.sh finished succesfull. Moving temp files to final.\n\n"

elif [ ${seqType} == "SR" ]
then
	${EBROOTBBMAP}/bbduk.sh -Xmx3g \
	in=${srBarcodeFqGz} \
	out=${srBarcodeFqGz}.tmp \
	ref=${EBROOTBBMAP}/resources/polyA.fa.gz,${EBROOTBBMAP}/resources/truseq.fa.gz,${EBROOTBBMAP}/resources/polyG.fa.gz \
	overwrite=true \
        k=13 \
	ktrim=l \
        qtrim=rl \
        trimq=14 \
        minlength=20 \
        forcetrimleft=11

	gzip ${srBarcodeFqGz}.tmp
	mv ${srBarcodeFqGz}.tmp.gz ${srBarcodeFqGz}

	echo -e "\nBBMap bbduk.sh finished succesfull. Moving temp files to final.\n\n"
fi
