#MOLGENIS walltime=5:00:00 nodes=1 cores=1 mem=4

#FOREACH projectDir
GenotypeCallingJar=${GenotypeCallingJar}
genotypeDir=${genotypeDir}
projectDir=${projectDir}
filePrefix=${filePrefix}

echo -e "GenotypeCallingJar=${GenotypeCallingJar}\ngenotypeDir=${genotypeDir}\nprojectDir=${projectDir}\nfilePrefix=${filePrefix}"

<#noparse>
mkdir -p ${genotypeDir}/SNVMix-TriTyper/
java -Xmx4g \
-jar ${GenotypeCallingJar} \
--mode SNVMixToTriTyper \
--in ${projectDir}/mappedData_masked/ \
--out ${genotypeDir}/SNVMix-TriTyper/ \
--pattern ${filePrefix}.mpileup.snvmix \
--p-value 0.95 \
--dosage False
</#noparse>
