## MOLGENIS pipelines

### Pipelines

This repository contains the following pipelines:
* Imputation
* RNA-seq (Experimental)

It also contains pipelines with their own repo's like:
* [NGS_DNA](https://www.gitbook.com/book/molgenis/ngs_dna)
* NGS_RNA

In addition it contains protocols that may be re-used between different (versions of a) pipeline(s).

### How to get started

Below we explain (step 1) how to download and deploy Molgenis Compute. This distribution already contains several pipelines/protocols/parameter files which you can use 'out-of-the-box' to align and impute your NGS data. Next, we explain (step 2) how you can download even more pipelines and protocols by cloning this repo.

For a 'walkthrough' tutorial on Molgenis Compute, please [go here](https://molgenis.gitbooks.io/molgenis-pipelines/content/pipelines/mc-start.html)

### Step 1: download Molgenis Compute
* Download the latest MOLGENIS Compute from https://github.com/molgenis/molgenis-compute/releases

* Currently (April 2017) MOLGENIS Compute v1.4 (16.11.1)

#### create dir
```
mkdir mycompute
cd mycompute
```
#### download
```
wget https://github.com/molgenis/molgenis-compute/releases/download/v16.11.1/molgenis-compute-v16.11.1.tar.gz
tar -xzvf molgenis-compute-v16.11.1.tar.gz
mv molgenis_compute-\<version>/* .  
```
#### test
```
sh molgenis_compute.sh  
```
### Step 2: clone this repo

#### For read/write access:
```
git clone https://github.com/molgenis/molgenis-pipelines.git
```

{% include "./SUMMARY.md" %}
