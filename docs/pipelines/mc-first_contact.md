# What is MOLGENIS Compute?

MOLGENIS Compute is a tool to generate shell script files for big data workflows that can run in parallel on clusters and grids.

The code is open source and hosted on GitHub.
http://github.com/molgenis/molgenis-compute

The software is licensed under the LGPL license.

# Download
You can download the [latest version of MOLGENIS Compute](https://github.com/molgenis/molgenis-compute/releases) from GitHub.

# Some Terms
In MOLGENIS Compute, **Data** is processed using a **Workflow** that consists of a series of **Steps** that depend on each other. Each **Step** follows a **Protocol**, which is a parameterized **Template** for the shell script for that **Step**.

# Demo
## Create a workflow
We assume you have downloaded and unzipped molgenis compute commandline and are now in the directory containing the unzipped files.

You can generate a template for a new workflow using the command:

```bash
  sh molgenis_compute.sh --create myfirst_workflow
```

This will create a new directory for the workflow:

```bash
  cd myfirst_workflow
  ls
```

The directory contains a typical Molgenis Compute workflow structure

file | description
---------|----
`/protocols` |  folder with bash script Protocols
`/protocols/step1.sh` | Shell script template for the first protocol
`/protocols/step2.sh` | Shell script template for the second protocol
`workflow.csv` | file listing steps and parameter flow
`workflow.defaults.csv` | default parameters for workflow.csv (optional)
`parameters.csv` | parameters you want to run analysis on
`header.ftl` | user extra script header (optional)
`footer.ftl` | user extra script footer (optional)

## Steps
Take a look at the generated workflow called `workflow.csv`

step|protocol|dependencies
----|--------|----------
step1|protocols/step1.sh|in=input
step2|protocols/step2.sh|wf=workflowName;date=creationDate;strings=step1.out

![image](../images/compute/workflow.png?raw=true, "the Workflow")

The workflow consists of two steps, `step1` and `step2`.

`step1` has protocol `protocols/step1.sh`, `step2` has protocol `protocols/step2.sh`

## Protocols
Let's take a look at one of the protocol templates.
Open `protocols/step1.sh`

```
#string in
#output out

# Let's do something with string 'in'
echo "${in}_hasBeenInStep1"
out=${in}_hasBeenInStep1
```

In the header of the template file, the input parameter `in` and output value `out` are declared.

When generating the job scripts for step 1, the value for the input parameter `in` will be inserted
into the template in those places where `${in}` is written.

## Parameters
In Molgenis Compute, anything can be a parameter.

* the name of a working directory
* the version number for a tool to use
* the name of a sample to analyze
* the amount of memory allocated for a cluster job
* the name of a report to produce

You can specify parameter values at generation time in parameter files.
In fact, for some parameters you may want to specify multiple values.

In this workflow, the parameter values are listed in two files:

### parameters.csv
|input|
|-----|
|hello|
|bye  |

The `input` parameter has two different values, hello and bye.
In `step1`, the `input` parameter gets mapped to the `in` parameter of `protocols/step1.sh`.
The parameter file lists two values for this parameter so this script will be created twice, one version for `input=hello`, and one for `input=bye`

### workflow.defaults.csv
|workflowName|creationDate|
|------------|------------|
|myFirstWorkflow|today    |

These parameter values will be inserted into the template for `step2`.
Let's take a look at `protocols/step2.sh`

```
#string wf
#string date
#list strings

echo "Workflow name: ${wf}"
echo "Created: ${date}"

echo "Result of step1.sh:"
for s in "${strings[@]}"
do
    echo ${s}
done


echo "(FOR TESTING PURPOSES: your runid is ${runid})"
```

The first three lines are the header listing the input parameters of the protocol.
In `step2` the parameter value `workflowName=myFirstWorkflow` from file `workflow.defaults.csv`
is mapped to protocol input `wf`. So when the script for `step2` gets generated, the
value `myFirstWorkflow` will be inserted where it says `${wf}`.

The output from `step1.sh` is parameter value `step1.out`, and `step2` maps it to parameter `strings` of this protocol.

But `step1.sh` will be run twice! So `step1.out` will have two different values, namely `hello_hasBeenInStep1` and `bye_hasBeenInStep1`. Of course, we could run `step2` twice, once for each value of `step1.out`. But the protocol uses `#list` to indicate that it can process multiple values for this input parameter in one single go. So a single instance of `step2.sh` will be generated. The `strings` input parameter will have a list value `strings=hello_hasBeenInStep1,bye_hasBeenInStep1`.

## Generate
Let's see MOLGENIS Compute in action!

Go back to the molgenis compute directory and generate the scripts:

```bash
sh molgenis_compute.sh --generate --parameters myfirst_workflow/parameters.csv --workflow myfirst_workflow/workflow.csv --defaults myfirst_workflow/workflow.defaults.csv
```

Take a look at the generated scripts in `rundir`

file | description
---------|----
`step1_0.sh`, `step1_1.sh`|	 the two scripts for `step1`, one for each value of the `input` parameter
`step2_0.sh`| the script for `step2`
`submit.sh`| a submission script, which will run the generated script files in the correct order
`user.env`| the user environment, containing runtime parameter values as input the steps.

## Run it
We've not specified a backend when we generated the scripts. By default the `submit.sh` will be generated for the `localhost` backend which simply calls the generated scripts in the right order.

## Clean up the rundir
```bash
sh molgenis_compute.sh --run
```

The scripts will be run, in particular you can see that the results from `step1` are correctly passed on to `step2` which `echo`s them:

```
Workflow name: myFirstWorkflow
Created: today
Result of step1.sh:
hello_hasBeenInStep1
bye_hasBeenInStep1
(FOR TESTING PURPOSES: your runid is oz5N)
```
