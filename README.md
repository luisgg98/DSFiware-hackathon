# DSFiware-hackathon
DS infrastructure to be deployed at the 241126-27 Nov Hackathon of Madrid (ITA,Capillar,UPM,Fiware,Decarbomille)

- [DSFiware-hackathon](#dsfiware-hackathon)
  - [_Install the tools to ease the life during deployment_](#install-the-tools-to-ease-the-life-during-deployment)
  - [Deployment of apisix as proxy](#deployment-of-apisix-as-proxy)
  - [Deployment of the Verifiable Data Registry components (Trust-Anchor)](#deployment-of-the-verifiable-data-registry-components-trust-anchor)
  - [Consumer's infrastructure](#consumers-infrastructure)

## [_Install the tools to ease the life during deployment_](./assets/docs/README-preparationGuide.md)
This section installs the components to be used during the deployment of the components.  
See the [Preparation Guide guide](./assets/docs/README-preparationGuide.md)

## [Deployment of apisix as proxy](./assets/docs/README-apisix.md)
This section describes the steps to test the kubernetes environment while deploying the Apisix Gateway.  
See the [apisix deployment guide](./assets/docs/README-apisix.md)

## [Deployment of the Verifiable Data Registry components (Trust-Anchor)](./assets/docs/README-trustAnchor.md)
This section describes the setup to deploy the components of the Verifiable Data Registry.  
See the [trust-anchor deployment guide](./assets/docs/README-trustAnchor.md)

## [Consumer's infrastructure](./assets/docs/README-consumer.md)
Any participant willing to consume services provided by the data space will require a minimum infrastructure that will enable the management of Verifiable Credentials besides a Decentralized Identifier that will constitue the signing mechanism to authenticate any message, any request made by the consumer.   
This section describes the steps and the components to be deployed.  
See the [consumer deployment guide](./assets/docs/README-consumer.md)