# MOLGENIS pipelines

## Pipelines

This repository contains the following pipelines:
* Alignment
* Imputation
* GWAS
* RNA-seq (Experimental)

In addition it contains protocols that may be re-used between different (versions of a) pipeline(s).

## How to get started

Below we explain (step 1) how to download and deploy Molgenis Compute. This distribution already contains several pipelines/protocols/parameter files which you can use 'out-of-the-box' to align and impute your NGS data. Next, we explain (step 2) how you can download even more pipelines and protocols by cloning this repo.

For a 'walkthrough' tutorial on Molgenis Compute, please visit https://github.com/molgenis/molgenis_apps-legacy/blob/testing/doc/compute/01_compute_introduction.md

### Step 1: download Molgenis Compute
	# Download the latest MOLGENIS Compute from http://www.molgenis.org/wiki/ComputeStart
	# Currently (March 2013) http://www.molgenis.org/raw-attachment/wiki/ComputeStart/molgenis_compute-fb05467.zip

	# create dir
	mkdir mycompute
	cd mycompute
	
	# download
	wget http://www.molgenis.org/raw-attachment/wiki/ComputeStart/molgenis_compute-fb05467.zip
	unzip molgenis_compute-\<version>.zip
	mv molgenis_compute-\<version>/* .  
	  
	# test  
	sh molgenis_compute.sh  

### Step 2: clone this repo
	
	# For read/write access:
	git clone https://github.com/molgenis/molgenis-pipelines.git
	# Alternatively to only download the pipelines use:
	wget https://github.com/molgenis/molgenis-pipelines/archive/master.zip
	unzip master
