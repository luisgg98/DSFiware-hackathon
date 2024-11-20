# Step00: Deployment of devops tools

- [Step00: Deployment of devops tools](#step00-deployment-of-devops-tools)
  - [Introduction](#introduction)
  - [Tools](#tools)
  - [Notes](#notes)

## Introduction
This section installs the software tools used during the deployment of the fiware Data Space components.  

## Tools
- Deploy [devopTools](https://github.com/cgonzalezITA/devopsTools) and follow its [README.md](https://github.com/cgonzalezITA/devopsTools/blob/master/README.md) to deploy tem. This document refers to the devoptTools commands to execute the actions.
 

## Notes
- To get familiar with some Helm basic commands, you can visit the section [_Helm Repo operations_](https://github.com/cgonzalezITA/devopsTools/tree/master/hTools#readme) of the [devop Tools](https://github.com/cgonzalezITA/devopsTools).  
- Before a Helm chart can be used, a command to update the referenced dependencies has to be executed. The hFileCommand provides the -b flag to run this command. his process will create inside the Helm chart folder a subfolder named ./chart with the charts used in the specific Helm.  
Next scripts show the deployment of the provider service helm chart:
  ```shell
  # Deployment of a Helm chart without the dependencies installed.
  hFileCommand service 
      Running CMD=[helm -n provider install -f "./Helms/provider/services(dataplane)/values.yaml" services "./Helms/provider/services(dataplane)/"  --create-namespace]
      Error: INSTALLATION FAILED: An error occurred while checking for chart dependencies. You may need to run `helm dependency build` to fetch missing dependencies: found in Chart.yaml, but missing in charts/ directory: scorpio, postgresql

  # Deployment of a Helm chart 'building' the dependencies installed.
  hFileCommand service -b
      # Running command [helm -n provider dependency update './Helms/provider/services(dataplane)/' ]
      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "bitnami" chart repository
      Update Complete. ⎈Happy Helming!⎈
      # Running command [helm -n provider dependency build './Helms/provider/services(dataplane)/' ]
      ...
      # Running CMD=[helm -n provider install -f "./Helms/provider/services(dataplane)/values.yaml" services "./Helms/provider/services(dataplane)/"]
      ...      
  ```