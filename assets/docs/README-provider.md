# Provider's infrastructure
- [Provider's infrastructure](#providers-infrastructure)
  - [Step4.1- _Deployment of the authentication components_](#step41--deployment-of-the-authentication-components)
    - [Verification of the deployment](#verification-of-the-deployment)

    
The objective of this phase is to deploy the following infrastructure.
<p style="text-align:center;font-style:italic;font-size: 75%"><img src="./../images/provider-components.png"><br/>
    Provider components</p>

Any organization willing to market their data and or services in a dataspace will require such infrastructure to manage:
- **The authentication phase**: Its components are represented by the yellow blocks at the *Provider components diagram*.  
  They analyze that any request made to the provider's services are made by a known and verified participant.
- **The authorization phase**: Its components are represented by the green blocks at the *Provider components diagram*.  
  They analyze that any request made to their services are made by a participant entitled to perform the requested action.
- **The data and or services offered**. Its components are represented by the purple blocks at the *Provider components diagram*.  
  This walkthrough shows the deployment of a [Context Data broker Scorpio](https://scorpio.readthedocs.io/en/latest/) to provide NGSI-LD data access.
    
## Step4.1- _Deployment of the authentication components_
The Helm chart used is located at [the Helm provider authentication's folder](../../Helms/provider/authentication(verif+credentConfigSvc+til)) and contains the following components:
- A did:web `did:web:fiwaredsc-provider.ita.es` component to provide a decentralized identifier to the provider, used to sign the messages generated at the provider's side.
- [Fiware Trusted Issuers List](https://github.com/FIWARE/trusted-issuers-list), It is the same component than the _Fiware Trusted Issuers List_ deployed at the trustAnchor. It plays the role of providing a [Trusted Issuers List API](https://github.com/FIWARE/trusted-issuers-list/blob/main/api/trusted-issuers-list.yaml) to manage the issuers in the provider.
- A [Credential Config Service](https://github.com/FIWARE/credentials-config-service): This service manages the Trusted issuer registries and the Trusted issuer local registries to be used to permorm the credential authentication. It enables the support the use of multiple trust anchors.
- A [VCVerifier](https://github.com/FIWARE/VCVerifier) that provides the necessary endpoints(see [API](https://github.com/FIWARE/VCVerifier/blob/main/api/api.yaml)) to offer [SIOP-2](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html#name-cross-device-self-issued-op)/[OIDC4VP](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#request_scope) compliant authentication flows. It exchanges VerfiableCredentials for JWT, that can be used for authorization and authentication in down-stream components.

### Verification of the deployment
Besides checking that the pods have been properly deployed, a number of curl requests can be made to verfy the set:
```json
# Checks the trusted issuer list:
kExec net -- curl http://til:8080/v4/issuers/
  {"self":"/v4/issuers/","items":[],"total":0,"pageSize":0,"links":null}

# Checks the credential config service:
kExec net -- curl http://cconfig:8080/service
  {"total":0,"pageNumber":0,"pageSize":0,"services":[]}

# Checks the verifier
kExec net --curl http://verifier:3000/health
  {"status":"OK","component":{"name":"vcverifier","version":"" } }

# 
```