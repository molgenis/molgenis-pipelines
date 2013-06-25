#MOLGENIS walltime=5:00:00 nodes=1 cores=1 mem=4

bamToBed="${bamToBed}"
sortedBam="${sortedBam}"
FluxCapacitor="${FluxCapacitor}"
annotationGtf="${annotationGtf}"
gtfExpression="${gtfExpression}"


<#noparse>

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ngtfExpression=${gtfExpression}"

bedFile=${sortedBam//bam/bed}

echo "Converting bam to bed (bedFile=$bedFile)"

${bamToBed} \
-bed12 \
-i ${sortedBam} \
> ${bedFile}

rm $gtfExpression


pairedCount=`samtools view -f 2 -c ${sortedBam}`

if [ $pairedCount -eq "0" ]; then
	
	echo "Quantifying the expression of single-end RNA-seq data"
	echo "output=$gtfExpression"
	
	${FluxCapacitor} \
		-i "$bedFile" \
		-a "$annotationGtf" \
		-o "$gtfExpression" \
		-m SINGLE \
		-d SIMPLE \
		-r true

else

	echo "Quantifying the expression of paired-end RNA-seq data"
	echo "output=$gtfExpression"

	${FluxCapacitor} \
		-i "$bedFile" \
		-a "$annotationGtf" \
		-o "$gtfExpression" \
		-m PAIRED \
		-d PAIRED \
		-r true
fi

rm -f "$bedFile"

</#noparse>
