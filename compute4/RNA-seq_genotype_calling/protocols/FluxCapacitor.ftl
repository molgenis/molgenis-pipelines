#MOLGENIS walltime=5:00:00 nodes=1 cores=1 mem=4

bamToBed="${bamToBed}"
sortedBam="${sortedBam}"
FluxCapacitor="${FluxCapacitor}"
annotationGtf="${annotationGtf}"

echo -e "bamToBed=${bamToBed}\nsortedBam=${sortedBam}\nFluxCapacitor=${FluxCapacitor}\nannotationGtf=${annotationGtf}"

<#noparse>
bedFile=${sortedBam//bam/bed}
expressionFlux=${sortedBam//bam/flux.gtf}

echo "Converting bam to bed (bedFile=$bedFile)"

${bamToBed} \
-bed12 \
-i ${sortedBam} \
> ${bedFile}

rm $expressionFlux

if [ $seqType == "SE" ]; then
 echo "Quantifying the expression of single-end RNA-seq data"
 echo "output=$expressionFlux"
 ${FluxCapacitor} \
 -i "$bedFile" \
 -a "$annotationGtf" \
 -o "$expressionFlux" \
 -m SINGLE \
 -d SIMPLE \
 -r true

else
 echo "Quantifying the expression of paired-end RNA-seq data"
 echo "output=$expressionFlux"
 ${FluxCapacitor} \
 -i "$bedFile" \
 -a "$annotationGtf" \
 -o "$expressionFlux" \
 -m PAIRED \
 -d PAIRED \
 -r true
fi

gzip "$bedFile"

</#noparse>
