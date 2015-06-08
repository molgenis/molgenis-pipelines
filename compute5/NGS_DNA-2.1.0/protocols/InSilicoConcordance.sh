#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=00:20:00

#string sample
#string simulatedPhiXVariantsSample
#string detectedPhiXVariantsSample
#string inSilicoConcordanceFile
#string project

sim=`tail -4 ${simulatedPhiXVariantsSample}`
det=`tail -4 ${detectedPhiXVariantsSample}`

if [ "$sim" = "$det" ]; then
    echo "Spiked phiX reads found in sample ${sample}" >> ${inSilicoConcordanceFile}
else
    echo "Spiked phiX reads NOT found in sample ${sample}" >> ${inSilicoConcordanceFile}
fi
