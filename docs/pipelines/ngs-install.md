### 1) Installing NGS_DNA

We first have to load EasyBuild, this can be done with this command
```bash
module load EasyBuild
```

The NGS_DNA pipeline has a lot of dependencies, these are handled by easybuild when the --robot command is executed (all the dependencies can be found [here](ngs-dependencies)). Since we have also our own repo we have to give the path to that also. There can be multiple paths to easybuild configs, just separate them by colon.

**_Note:_** the order in which you give the paths are important! To original easybuild path can be left empty (just a colon is enough)
```bash
eb NGS_DNA-3.2.3.eb --robot --robot-paths=${pathToMYeasybuild}/easybuild-easyconfigs/easybuild/easyconfigs/:
```
**_Note:_** some software cannot be downloaded automagically due to for example licensing or technical issues and the build will fail initially.
In these cases you will have to download manually and copy the sources to
${HPC_ENV_PREFIX}/sources/[a-z]/NameOfTheSoftwarePackage/
This is the case for example for Java. Therefore:
```bash
scp jdk-7u80-linux-x64.tar.gz your_account@yourcluster.nl:${root}/apps/sources/j/Java/
scp jdk-8u45-linux-x64.tar.gz your_account@yourcluster.nl:${root}/apps/sources/j/Java/
```

but also tools as GATK, Tabix and snpEff should be download manually:
```bash
scp GATK-3.5.tar.gz your_account@yourcluster.nl: ${root}/apps/sources/g/GATK/
scp tabix.0.18.6.tar.gz your_account@yourcluster.nl: ${root}/apps/sources/t/tabix
scp snpEff-4.1g.tar.gz your_account@yourcluster.nl: ${root}/apps/sources/s/snpEff/
```
**_change config file of snpEff: data.dir=./data should be data.dir=${root}/apps/data/snpEff_**

### 2) Installing the necessary resources (reference genome, dbSNP etc)

Logout and login again.
Run the script NGS_resources to install the required resources, you can download the scripts [here](attachments/scripts.tar.gz)

```bash
sh NGS_DNA-resources.sh
```

This script will download parts of the 2.8 bundle from the GATK server

**_Note:_** Sometimes the GATK ftp server can be down/instable, try it a couple of times

### 3) Creating workdir structure
```bash
sh makestructure.sh
```
