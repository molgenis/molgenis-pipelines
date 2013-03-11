Type="Job";
JobType="Normal";

Executable = "/bin/sh";
Arguments = "${script_name}.sh";

StdError = "${error_log}";
StdOutput = "${output_log}";

InputSandbox = {"${script_location}/${script_name}.sh"};
OutputSandbox = {"${error_log}","${output_log}"};

Requirements = ((other.GlueCEInfoHostName == "creamce.gina.sara.nl" ||
     other.GlueCEInfoHostName == "phoebe.htc.biggrid.nl" ||
	 other.GlueCEInfoHostName == "gb-ce-ams.els.sara.nl" ||
	 other.GlueCEInfoHostName ==  "gb-ce-uu.science.uu.nl" ||
	 other.GlueCEInfoHostName == "gb-ce-tud.ewi.tudelft.nl" ||
	 other.GlueCEInfoHostName == "gb-ce-rug.sara.usor.nl" ||
	 other.GlueCEInfoHostName == "creamce.grid.rug.nl" ||
	 other.GlueCEInfoHostName == "ce.grid.rug.nl") && 
	 other.GlueCEPolicyMaxCPUTime >= 1440);


