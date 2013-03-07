# MOLGENIS pipelines

## Pipelines

This repository contains the following pipelines:
* Alignment
* Imputation

In addition it contains protocols that may be re-used between different (versions of a) pipeline(s).

## How to get started

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
	
	git clone https://github.com/molgenis/molgenis-legacy.git