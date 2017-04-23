## How does it work?

### Parameters
Parameters can be provided in text files, there are a couple of formats to choose from.

Say you want to specify the following four combinations of parameters:

|project |dir |sample |
|--------|----|-------|
|project1|dir1|sample1|
|project1|dir2|sample2|
|project1|dir2|sample3|
|project2|dir2|sample4|

We'll show how the following combination of parameters looks in each of the file formats.

#### Table format
This is an ordinary csv file with key names as headers on the first line.
The rest of the lines contain comma separated value combinations for those keys.

```
project, dir, sample
project1, dir1, sample1
project1, dir2, sample2
project1, dir2, sample3
project2, dir2, sample4
```

This is a normal CSV file so you'll need to surround the cell value with quotes in the csv format if you want to put a comma in the value.

#### Property format
This is a property file with key names as keys and comma separated value combinations for each key as a value.
All value lists must be the same size

```
project=project1,project1,project1,project2
dir=dir1,dir2,dir2,dir2
sample=sample1,sample2,sample3,sample4
```

This is parsed as a normal property file and the values are subsequently split on comma's (`,`).

#### List parameter values
A parameter value of the range format `i..j` will result in multiple rows, one for all values within the range.
So for example if you have provided (in any format) the parameter values

|project |value|
|--------|-----|
|project1|1..2 |
|project2|1..3 |

They will be expanded to

|project |value|
|--------|-----|
|project1|1    |
|project1|2    |
|project2|1    |
|project2|2    |
|project2|3    |

Similarly, a parameter value with a comma-separated list of values will result in multiple rows, one for all values in the list. Surround the value with quotes to escape commas, e.g. `"sample2,sample3"`.

So 

|project |dir |sample         |
|--------|----|---------------|
|project1|dir1|sample1        |
|project1|dir2|sample2,sample3|
|project2|dir2|sample4        |

Will be expanded to

|project |dir |sample |
|--------|----|-------|
|project1|dir1|sample1|
|project1|dir2|sample2|
|project1|dir2|sample3|
|project2|dir2|sample4|

#### Multiple files
You may specify multiple parameter files.
Each parameter may only be specified in one file.
The resulting list of parameters will be created by taking all possible combinations of parameter combinations from each file.

#### Simple example
Say we have the following parameter combinations:

|input|
|-----|
|hello|
|bye  |

and

|workflowName   |creationDate|
|---------------|------------|
|myFirstWorkflow|today       |

Then these will get combined to 

|input|workflowName   |creationDate|
|-----|---------------|------------|
|hello|myFirstWorkflow|today       |
|bye  |myFirstWorkflow|today       |

#### Example with three files

Say we have the following three files:

|input|
|-----|
|hello|
|bye  |

|sample |
|-------|
|sample1|
|sample2|

|workflowName   |creationDate|
|---------------|------------|
|myFirstWorkflow|today       |

Then these will get combined to 

|input|sample |workflowName   |creationDate|
|-----|-------|---------------|------------|
|hello|sample1|myFirstWorkflow|today       |
|hello|sample2|myFirstWorkflow|today       |
|bye  |sample1|myFirstWorkflow|today       |
|bye  |sample2|myFirstWorkflow|today       |

#### Collapsing (or Folding) the table of Parameter values
Say we have the following combinations:

|project |dir |sample |
|--------|----|-------|
|project1|dir1|sample1|
|project1|dir2|sample2|
|project1|dir2|sample3|
|project2|dir2|sample4|

Now if a particular step's protocol depends only on the value of parameter `project`, it only needs to be run twice, once for `project=project1` and once for `project=project2`.
So the table of parameter combinations can be collapsed to the much smaller table.

|project |
|--------|
|project1|
|project2|

If the step's protocol depends on parameters `project` and `dir`, three instances for the step need to be created, collapsing the table as follows:

|project |dir |
|--------|----|
|project1|dir1|
|project1|dir2|
|project2|dir2|

The step need not be run for the combination `project=project2, dir=dir1`, since no parameter combinations exist with those values.

#### environment files
Data is shared between steps using env files.
Those contain entries of the shape `name[index]=value`

Compute generates `user.env` which contains all inputs for all steps that are known at generation time.

At runtime, the steps may create files named *stepname*_*stepindex*.env. So for example `step1_0.sh` creates `step1_0.env`.

#### Weaving
Parameters which are known beforehand can also be **weaved** directly into the protocols
(if 'weave' flag is set in command-line options). In our example, two shell scripts are generated
for 'step1'. The weaved version of the generated files is shown below.

step1_0.sh:
```bash
  #string in
  #output out
  # Let's do something with string 'in'
  echo "hello_hasBeenInStep1"
  out=hello_hasBeenInStep1
```

and step1_1.sh
```bash
  #string in
  #output out
  # Let's do something with string 'in'
  echo "bye_hasBeenInStep1"
  out=bye_hasBeenInStep1
```

The output values of the first steps are not known beforehand, so, 'string' cannot be weaved and will stay in the generated for the 'step2' script as it was. However, the 'wf' and 'date' values are weaved.

step2_0.sh:
```bash
  #string wf
  #string date
  #list strings
  echo "Workflow name: myFirstWorkflow"
  echo "Created: today"
  echo "Result of step1.sh:"
  for s in "${strings[@]}"
  do
      echo ${s}
  done
```

If values can be known, the script will have the following content 

step2_0.sh with all known values:
```bash
  #string wf
  #string date
  #list strings
  echo "Workflow name: myFirstWorkflow"
  echo "Created: today"
  echo "Result of step1.sh:"
  for s in "hello" "bye"
  do
      echo ${s}
  done
```

If 'weaved' flag is not set, +step1_0.sh+ file, for example looks as follows:
```bash
  # Connect parameters to environment
  input="bye"
  #string input
  # Let's do something with string 'in'
  echo "${input}_hasBeenInStep1"
  out=${input}_hasBeenInStep1
```

In this way, users can choose how generated files look like.
In the current implementation, values are first taken from parameter files. If they are not present, then compute looks,
if these values can be known at run-time, by analysing all previous steps of the protocol, where values are unknown.
If values cannot be known at run-time, compute will give a generation error. 

### Protocol headers
#### Inputs and Outputs
Each Protocol lists its Input parameters and its Output values in the header


```
#string project
#string dir
#list sample
#output out1
#output out2
```

This header states that this Protocol depends on the values of three Input parameters named
`project`, `dir`, and `sample` and that when it is run it produces two Output values, namely
`out1` and `out2`.
The script can handle only a single combination of the `#string` parameters at a time, but the `#list` prefix means it can handle all existing values for out1 and out2. `out1` and `out2` will contain a list of all values.

Multiple inputs may be specified on one line, e.g.

```
#string project,dir
```

You can also use this for list inputs:

```
#list sample,dir
```
This is called "Combined lists notation".
TODO: Find out what's different about this notation

#### Resource parameters

A Protocol can list values for resource parameters in a MOLGENIS header, e.g.

```
#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6
```

The values specified in the protocol header will override the parameter values set in the parameter files.
Valid options are
	* queue
	* walltime
	* nodes
	* ppn
	* memory
	
#### Compute properties
Values specified on the command line as compute properties will be added to the parameter combinations and can be referenced in the Protocol Templates.
	
#### Description
A protocol can add a description in a `#description` header.

#### Parameter mapping

The Workflow csv file describes for each Step how the global Parameters are mapped to Protocol Inputs and Outputs. The global name is mapped to a local name that the Protocol understands.

### Templates
#### Types
If your protocol file name ends with `.ftl`, the parameter values will be weaved into the steps scripts.
If it ends with `.sh`, it will be left as is and the values will be inserted at runtime.

If you don't want a particular section of your template to be parsed, you can surround it with `<#noparse>` and `</#noparse>` tags.
But see (#245)[https://github.com/molgenis/molgenis-compute/issues/245]

#### Submit.sh
The generated scripts will be accompanied by a submission script `submit.sh`. The submission script will either run the scripts locally or send them to the backend you have selected.

#### Backends
There are three backends

 * localhost
 * pbs
 * slurm

The difference between the backends are found in the headers and footers that get added to the Protocol templates 
### molgenis-compute.sh
#### cleaning
When you are done with your workflow, make sure to run 

```
sh molgenis-compute.sh --clean
```
To clean up the temporary files.

#### Parameter override
You can override parameter values on the command line using `--override` or `-o`. For example: `-o mem=6GB;queue=long`

### Github workflows
You can use workflow files that are hosted online.
Specify the command line parameter `--web workflowRoot` where workflowRoot is the URL that will be prefixed to all of the files.