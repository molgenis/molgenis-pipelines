#  Installing NGS_RNA pipeline

This is the Quick tutorial, when there are problems first go to the detailed [install page](rna-install) or when there are problems [running the pipeline](rna-run)

We first have to load EasyBuild, this can be done with this command
```bash
module load EasyBuild
eb NGS_RNA-3.2.3.eb --robot -–robot-paths=${pathToMYeasybuild}/easybuild-easyconfigs/easybuild/easyconfigs/:
```
**_Note:_** some software cannot be downloaded automagically due to for example licensing or technical issues and the build will fail initially.
In these cases you will have to download manually and copy the sources to
${HPC_ENV_PREFIX}/sources/[a-z]/NameOfTheSoftwarePackage/ for more details check [install page](ngs-install)

Run the script NGS_resources to install the required resources and create directory structure, you can download the scripts [here](attachments/scripts.tar.gz)
```bash
sh makestructure.sh
sh NGS_RNA-resources.sh
```
**_Note:_** Sometimes the GATK ftp server can be down/instable, try it a couple of times


#  Preparing and running NGS_RNA pipeline

```bash
scp –r 198210_SEQ_RUNTEST_FLOWCELLXX username@yourcluster:${root}/groups/$groupname/${tmpDir}/rawdata/ngs/

mkdir ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun

scp –r TestRun username@yourcluster:/groups/$groupname/${tmpDir}/generatedscripts/

module load NGS_RNA
cd ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun
cp $EBROOTNGS_RNA/generate_template.sh .
sh generate_template.sh
cd scripts
```
**_Note:_** if you want to run locally, you should change in the CreateInhouseProjects.sh script the backend (this can be done almost at the end of the script where you have something like:
sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh
<u>search for –b slurm and change it into –b localhost</u>
```bash
sh submit.sh
```

navigate to jobs folder (this will be outputted at the step before this one).
```bash
sh submit.sh
```
