#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=2

#FOREACH sample

genotypeFolder="${genotypeFolder}"
phasedFolder="${phasedFolder}"
shapeitBin="${shapeitBin}"
JAVA_HOME="${JAVA_HOME}"
tooldir="${tooldir}"

sample="${sample}"
snvmixOut="${snvmixOut}"

<#noparse>

mkdir -p ${genotypeFolder}
mkdir -p ${phasedFolder}

echo "genotypeFolder=${genotypeFolder}"
echo "phasedFolder=${phasedFolder}"
echo "snvMixOuts=${snvmixOut}"
echo "samples=${sample}"

rm -f ${genotypeFolder}/fileList.txt




echo -e  "${sample}\t${snvmixOut}" >> ${genotypeFolder}/fileList.txt


 ${JAVA_HOME}/bin/java \
          -Xmx2g \
          -jar /target/gpfs2/gcc/home/dasha/scripts/genotyping/GenotypeCalling/dist/GenotypeCalling.jar \
          --mode SNVMixToGen \
          --fileList ${genotypeFolder}/fileList.txt \
          --p-value 0.8 \
          --out ${genotypeFolder}/___tmp___${sample}chr

 returnCode=$?
 echo "Return code ${returnCode}"

 if [ "${returnCode}" -eq "0" ]
 then
	
	 echo "Moving temp files: ${genotypeFolder}/___tmp___${sample}chr* to ${genotypeFolder}/${sample}chr*"
	 tmpFiles="${genotypeFolder}/___tmp___${sample}chr*"
	 for f in $tmpFiles
	 do
		 mv $f ${f//___tmp___/}
	 done
	
 else
  
	 echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	 exit 1
	
 fi


for chr in {1..22}
do
		
		sort -k3,3n ${genotypeFolder}/${sample}chr${chr}.gen > ${genotypeFolder}/${sample}chr${chr}.sorted.gen

    /target/gpfs2/gcc/tools/Shapeit-v2.644/shapeit.v2.r644.linux.x86_64 \
        -check \
        --input-gen ${genotypeFolder}/${sample}chr${chr}.sorted.gen ${genotypeFolder}/${sample}chr.sample \
        --input-ref /target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.hap.gz /target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.legend.gz  /target/gpfs2/gcc/resources/impute2Reference/gonl5/gonl5.sample\
        --output-log ${genotypeFolder}/${sample}chr${chr}Check \
        --input-thr 0.8 \
     
     
     
     
	 /target/gpfs2/gcc/tools/Shapeit-v2.644/shapeit.v2.r644.linux.x86_64 \
        --input-gen ${genotypeFolder}/${sample}chr${chr}.sorted.gen ${genotypeFolder}/${sample}chr.sample \
        --input-ref /target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.hap.gz /target/gpfs2/gcc/resources/impute2Reference/gonl5/chr${chr}.legend.gz  /target/gpfs2/gcc/resources/impute2Reference/gonl5/gonl5.sample\
        --output-log ${phasedFolder}/___tmp___${sample}chr${chr} \
        --output-max ${phasedFolder}/___tmp___${sample}chr${chr} \
        --input-map /target/gpfs2/gcc/resources/geneticMap/hapmapPhase2/b37/genetic_map_chr${chr}_combined_b37.txt \
        --input-thr 0.8 \
        --exclude-snp ${genotypeFolder}/${sample}chr${chr}Check.snp.strand.exclude \
        --no-mcmc \
        --thread 1
        
        
     returnCode=$?
	 echo "Return code ${returnCode}"
	
	 if [ "${returnCode}" -eq "0" ]
	 then
		
		 echo "Moving temp files: ${phasedFolder}/___tmp___${sample}chr${chr}* to ${phasedFolder}/${sample}chr${chr}*"
		 tmpFiles="${phasedFolder}/___tmp___${sample}chr${chr}*"
		 for f in $tmpFiles
		 do
			 mv $f ${f//___tmp___/}
		 done
		
	 else
	  
		 echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
		#Return non zero return code
		 exit 1
		
	 fi
	
    
done



</#noparse>
