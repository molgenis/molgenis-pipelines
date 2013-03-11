#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

getFile ${impute2ResultsBinsLocation}
getFile ${tooldir}/python_scripts/AssemblyImpute2GprobsBins.py

module load Python/2.7.3

python -c 'import os; a = lambda chromosome, ffrom, tto : [z[1] for z in [[y[1].split("_"), y[2]] for y in [x.split() for x in open("${impute2ResultsBinsLocation}")]] if z[0][0][3:] == chromosome and z[0][4] == str(ffrom) and z[0][5] == str(tto) and z[1] != "NO_SNP"]; b = lambda chromosome, ffrom, tto : ["getFile " + x for x in a(chromosome, ffrom, tto)] + [" ".join(["cat"] + a(chromosome, ffrom, tto) + [">", os.path.join("${gprobsBinsDir}", "_".join(["chr", chromosome, ffrom, tto]))])]; [map(os.system, b("${chr}", str(x), str(x+${sampleBins}-1))) for x in range(0, ${samples}, ${sampleBins})]'

#getFile ${gprobsBinsDir}/chr1_0_499
#getFile ${gprobsBinsDir}/chr1_500_999
#getFile ${gprobsBinsDir}/chr1_1000_1499
#getFile ${gprobsBinsDir}/chr1_1500_1999
#getFile ${gprobsBinsDir}/chr1_2000_2499
#getFile ${gprobsBinsDir}/chr1_2500_2999
#getFile ${gprobsBinsDir}/chr1_3000_3499
#getFile ${gprobsBinsDir}/chr1_3500_3999
#getFile ${gprobsBinsDir}/chr1_4000_4499
#getFile ${gprobsBinsDir}/chr1_4500_4999

inputs "${impute2ResultsBinsLocation}"


python -V

mkdir -p ${resultsDir}
python ${tooldir}/python_scripts/AssemblyImpute2GprobsBins.py ${gprobsBinsDir} 500 10 ${chr} ${resultsDir}/OUTPUT.gprobs


putFile ${resultsDir}/OUTPUT.gprobs

