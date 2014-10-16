#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string intermediateDir

#string gatkVersion
#string dbsnpVcf
#string dbsnpVcfIdx
#string onekgGenomeFasta
#list bsqrBam
#list bsqrBam

#string haplotyperDir
#string haplotyperVcf
#string haplotyperVcfIdx

#string annotatorDir
#string snpEffVersion
#string snpEffStats
#string snpEffVcf
#string snpEffVcfIdx
#string annotVcf
#string annotVcfIdx
#string cosmicVcf
#string cosmicVcfIdx

#snpEff stuff
#string motifBin
#string nextProtBin
#string pwmsBin
#string regulation_CD4Bin
#string regulation_GM06990Bin
#string regulation_GM12878Bin
#string regulation_H1ESCBin
#string regulation_HeLaS3Bin
#string regulation_HepG2Bin
#string regulation_HMECBin
#string regulation_HSMMBin
#string regulation_HUVECBin
#string regulation_IMR90Bin
#string regulation_K562bBin
#string regulation_K562Bin
#string regulation_NHABin
#string regulation_NHEKBin
#string snpEffectPredictorBin


alloutputsexist \
"${annotVcf}" \
"${annotVcfIdx}"

echo "## "$(date)" ##  $0 Started "

#tired of typing getfile....
for file in "${bsqrBam[@]}" "${bsqrBai[@]}" "${dbsnpVcf}" "${dbsnpVcfIdx}" "${onekgGenomeFasta}" "${haplotyperVcf}" "${haplotyperVcfIdx}" "${cosmicVcf}" "${cosmicVcfIdx}" "${regulation_CD4Bin}"  "${regulation_GM06990Bin}"  "${regulation_GM12878Bin}"  "${regulation_H1ESCBin}"  "${regulation_HeLaS3Bin}"  "${regulation_HepG2Bin}"  "${regulation_HMECBin}"  "${regulation_HSMMBin}"  "${regulation_HUVECBin}"  "${regulation_IMR90Bin}"  "${regulation_K562bBin}"  "${regulation_K562Bin}"  "${regulation_NHABin}"  "${regulation_NHEKBin}"  "${snpEffectPredictorBin}" ; do
	echo "getFile file='$file'"
	getFile $file
done

#Load snpeff/gatk module
${stage} snpEff/${snpEffVersion}
${stage} GATK/${gatkVersion}
${checkStage}

#${addOrReplaceGroupsBam} sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bsqrBam[@]}" | sort -u ))
inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${annotatorDir}

#pseudo: java -Xmx4g -jar $SnpEffJar \
#		 -c $SnpEffConfig \
#		 -v -o gatk \
#		 GRCh37.74 \
#		 $UGvcf \
#		1>$SnpEffvcf \
#		2>$MainDir/$LogDir/$PatientBase.$Prog.err.log \
#java -Xmx4g -jar $GatkJar \
#		 -T VariantAnnotator \
#		 -R $refFile \
#		 -D $dbSnpVcf \
#		 --filter_bases_not_stored \
#		 --useAllAnnotations \
#		 --excludeAnnotation MVLikelihoodRatio \
#		 --excludeAnnotation TechnologyComposition \
#		 --excludeAnnotation DepthPerSampleHC \
#		 --excludeAnnotation PercentNBaseSolid \
#		 --excludeAnnotation StrandBiasBySample \
#		 --snpEffFile $SnpEffvcf \
#		 --resource:cosmic,vcf $cosmicVcf \
#		 -E 'cosmic.ID' \
#		 --resource:1000g,vcf $oneKgP1wgsVcf \
#		 -E '1000g.AF' \
#		 -E '1000g.AFR_AF' \
#		 -E '1000g.AMR_AF' \
#		 -E '1000g.ASN_AF' \
#		 -E '1000g.EUR_AF' \
#		 --resource:dbSnp,vcf $dbSnpVcf \
#		 -E 'dbSnp.ASP' \
#		 -E 'dbSnp.ASS' \
#		.... \
#		 -E 'dbSnp.WTD' \
#		 -E 'dbSnp.dbSNPBuildID' \
#		 -V $UGvcf \
#		 -o $Annotvcf \
#		  ${ unifiedGenotyperInputBams[*] } \
#		 -L $UGvcf \
#		1>$Check \
#		2>$MainDir/$LogDir/$PatientBase.$Prog.err.log 


if [ ! -e ${snpEffVcf} ] || [ ! -s ${snpEffVcf} ]; then 
	java -Xmx4g -jar  $SNPEFF_HOME/snpEff.jar \
	 -c $SNPEFF_HOME/snpEff.config \
	 -stats ${snpEffStats} \
         -v -o gatk \
	 GRCh37.75 \
	 ${haplotyperVcf} \
	 1>${snpEffVcf}
fi

#review  --excludeAnnotation MVLikelihoodRatio 

java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
 -T VariantAnnotator \
 -R ${onekgGenomeFasta} \
 --dbsnp ${dbsnpVcf} \
 ${inputs[@]} \
 --excludeAnnotation MVLikelihoodRatio \
 --excludeAnnotation TechnologyComposition \
 --excludeAnnotation DepthPerSampleHC \
 --excludeAnnotation PercentNBaseSolid \
 --filter_bases_not_stored \
 --useAllAnnotations \
 --snpEffFile ${snpEffVcf} \
 --resource:cosmic,VCF ${cosmicVcf} \
 -E 'cosmic.ID' \
 -V:input,VCF ${haplotyperVcf} \
 --out ${annotVcf} \
 -L ${haplotyperVcf} \
 --unsafe ALLOW_N_CIGAR_READS 

# maybe nececary
# -U LENIENT_VCF_PROCESSING
# -U ALLOW_N_CIGAR_READS

#rm ${snpEffVcf} ${snpEffVcfIdx}

putFile ${annotVcf}
putFile ${annotVcfIdx}

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
