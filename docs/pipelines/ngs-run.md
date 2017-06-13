# 3) Preparing and running NGS_DNA pipeline

### 1) Copy rawdata to rawdata ngs folder
```bash
scp –r SEQSTARTDATE_SEQ_RUNTEST_FLOWCELLXX username@yourcluster:${root}/groups/$groupname/${tmpDir}/rawdata/ngs/
```
### 2) Create a folder in the generatedscripts folder
```bash
mkdir ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun
```
### 3) Copy samplesheet to generatedscripts folder
```bash
scp –r TestRun.csv username@yourcluster:/groups/$groupname/${tmpDir}/generatedscripts/
```
**_Note: the name of the folder should be the same as samplesheet (.csv) file_**

### 4) Run the generate script
```bash
module load NGS_DNA
cd ${root}/groups/$groupname/${tmpDir}/generatedscripts/TestRun
cp $EBROOTNGS_DNA/generate_template.sh .
sh generate_template.sh
cd scripts
```

**_Note:_** if you want to run locally, you should change in the CreateInhouseProjects.sh script the backend (this can be done almost at the end of the script where you have something like:
sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh
<u>search for –b slurm and change it into –b localhost</u>
```bash
sh submit.sh
```
### 5) Submit jobs

navigate to jobs folder. The location of the jobs folder will be outputted at the step before this one (step 4).
```bash
sh submit.sh
```
