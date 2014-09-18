Type="Job";
JobType="Normal";

Executable = "/bin/sh";
Arguments = "${script_name}.sh";

StdError = "${error_log}";
StdOutput = "${output_log}";

InputSandbox = {"${script_location}/${script_name}.sh${extra_inputs}"};
OutputSandbox = {"${error_log}","${output_log}"${extra_outputs}};

Requirements = other.GlueCEUniqueID == "ce.grid.rug.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="gb-ce-tud.ewi.tudelft.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="gb-ce-nki.els.sara.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="gb-ce-lumc.lumc.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="gb-ce-rug.sara.usor.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="gb-ce-ams.els.sara.nl:8443/cream-pbs-medium" 
|| other.GlueCEUniqueID =="creamce.grid.rug.nl:8443/cream-pbs-medium";
