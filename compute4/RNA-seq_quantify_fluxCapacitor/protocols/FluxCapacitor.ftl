#MOLGENIS walltime=24:00:00 nodes=1 cores=2 mem=7

bamToBed="${bamToBed}"
sortedBam="${sortedBam}"
FluxCapacitor="${FluxCapacitor}"
annotationGtf="${annotationGtf}"
gtfExpression="${gtfExpression}"


<#noparse>

export FLUX_MEM="6G";

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ngtfExpression=${gtfExpression}"

alloutputsexist ${gtfExpression}

bedFile=${sortedBam//bam/bed}

echo "Converting bam to bed (bedFile=$bedFile)"

${bamToBed} \
-bed12 \
-i ${sortedBam} \
> ${bedFile}

rm ${gtfExpression}___tmp___


pairedCount=`samtools view -f 2 -c ${sortedBam}`

if [ $pairedCount -eq "0" ]; then
	
	echo "Quantifying the expression of single-end RNA-seq data"
	
	echo "Temp output: ${gtfExpression}___tmp___"
	
	${FluxCapacitor} \
		-i "$bedFile" \
		-a "$annotationGtf" \
		-o "${gtfExpression}___tmp___" \
		-m SINGLE \
		-d SIMPLE \
		-r true
		
		returnCodeFlux=$?

else

	echo "Quantifying the expression of paired-end RNA-seq data"
	
	echo "Temp output: ${gtfExpression}___tmp___"

	${FluxCapacitor} \
		-i "$bedFile" \
		-a "$annotationGtf" \
		-o "${gtfExpression}___tmp___" \
		-m PAIRED \
		-d PAIRED \
		-r true
		
	returnCodeFlux=$?
	
fi


echo "Flux Capacitor return code: ${returnCodeFlux}"

if [ $returnCodeFlux -eq 0 ]
then

	for tempFile in ${gtfExpression}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


rm -f "$bedFile"

</#noparse>
