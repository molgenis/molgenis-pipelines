# Command-line options

Molgenis Compute has the following command-line options:

```bash
  Version: development
  usage: sh molgenis-compute.sh -p parameters.csv
  -b,--backend <arg>                 Backend for which you generate.
                                     Default: localhost
  -bp,--backendpassword <arg>        Supply user pass to login to execution
                                     backend. Default is not saved.
  -bu,--backenduser <arg>            Supply user name to login to execution
                                     backend. Default is your own user
                                     name.
  -clear,--clear                     Clear properties file
  -create <arg>                      Creates empty workflow. Default name:
                                     myworkflow
  -d,--database <arg>                Host, location of database. Default:
                                     none
  -dbe,--database-end                End the database
  -dbs,--database-start              Starts the database
  -defaults,--defaults <arg>         Path to your workflow-defaults file.
                                     Default: defaults.csv
  -footer <arg>                      Adds a custom footer. Default:
                                     footer.ftl
  -g,--generate                      Generate jobs
  -h,--help                          Shows this help.
  -header <arg>                      Adds a custom header. Default:
                                     header.ftl
  -l,--list                          List jobs, generated, queued, running,
                                     completed, failed
  -mpass,--molgenispassword <arg>    Supply user pass to login to molgenis.
                                     Default is not saved.
  -mu,--molgenisuser <arg>           Supply user name to login to molgenis
                                     database. Default is your own user
                                     name.
  -o,--overwrite <arg>               Parameters and values, which will
                                     overwritten in the parameters file.
                                     Parameters should be placed into
                                     brackets and listed using equality
                                     sign, e.g. "mem=6GB;queue=long"
  -p,--parameters <parameters.csv>   Path to parameter.csv file(s).
                                     Default: parameters.csv
  -path,--path                       Path to directory this generates to.
                                     Default: <current dir>.
  -port,--port <arg>                 Port used to connect to databasae.
                                     Default: 8080
  -r,--run                           Run jobs from current directory on
                                     current backend. When using --database
                                     this will return a 'id' for --pilot.
  -rundir <arg>                      Directory where jobs are stored
  -runid,--runid <arg>               Id of the task set which you generate.
                                     Default: null
  -submit <arg>                      Set a custom submit.sh template.
                                     Default: submit.sh.ftl
  -w,--workflow <workflow.csv>       Path to your workflow file. Default:
                                     workflow.csv
  -weave,--weave                     Weave parameters to the actual script
  -web,--web <arg>                   Location of the workflow in the public
                                     github repository. The other
                                     parameters should be specified
                                     relatively to specified github root.
```

# Reserved words

Molgenis Compute has a list of reserved words, which cannot be used in compute to name 
parameters, workflow steps, etc. These words are listed below:

reserved words
```
  port			interval
  workflow		path
  defaults		parameters
  rundir		runid
  backend		database
  walltime		nodes
  ppn			queue
  mem			_NA
  password		molgenisuser
  backenduser		header
  footer		submit
  autoid
```

The reserved words are used in the compute.properties file. This file is created to save the latest compute configuration and discuss further.


# Script generation for PBS cluster and other back-ends

To generate for pbs, the next options should be added to the command line

```bash
--backend pbs
```

When generating script for computational clusters or grid, some additional parameters, such as execution wall-time, memory requirement, etc. should be specified. This can be done in the parameters file

parameters.csv
```
  workflowName,creationDate,queue,mem,walltime,nodes,ppn
  myFirstWorkflow,today,short_queue,4GB,05:59:00,1,1
```

Options:
* queue - cluster/grid queue
* mem - memory required
* walltime - execution wall time
* nodes - number of nodes needed
* ppn - number of cores needed
  
Or also it can be specified in the molgenis header in protocols

step1.ftl
```bash
  #MOLGENIS queue=short_queue mem=4gb walltime=05:59:00 nodes=1 ppn=1
  #string in
  #output out
  # Let's do something with string 'in'
  out=${in}_hasBeenInStep1
```

The specification in protocols has priority over specification in parameter files.

In the command-line distribution, users can add a new back-end by adding a new directory, that contains header/footer and submit templates for that backend.

# Switching to a different workflow

It is very advisable to start working with a new workflow with running 

```bash
sh molgenis_compute.sh --clear
```

This command clears the ```.compute.properties``` file, which contains previous generation and running options.

# Commenting in workflow specification

User can want to run only one or several steps of the workflow, when the rest of workflow can be commented out using '#' sign. In this example 'step2' is commented out.

workflow.csv
```
  step,protocol,dependencies
  step1,protocols/step1.sh,
  #step2,protocols/step2.sh,step1
```