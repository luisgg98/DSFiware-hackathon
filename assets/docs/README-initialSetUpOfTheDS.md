# Initial setup of the DS
- [Initial setup of the DS](#initial-setup-of-the-ds)
  - [Step 5.1-Addition of the service route to the Apisix with VC Authentication](#step-51-addition-of-the-service-route-to-the-apisix-with-vc-authentication)
  - [Bottom line](#bottom-line)

    
The objective of this phase is to explain the actions to register the participants in the dataspace and will continue the configuration to provide authentication and authorization mechanisms to the dataspace.  
This phase is tailored for this walkthrough scenario. Interactions to fully comply with the [DSBA Technical Convergence recommendations](https://data-spaces-business-alliance.eu/wp-content/uploads/dlm_uploads/Data-Spaces-Business-Alliance-Technical-Convergence-V2.pdf) are out of the scope of this guideline (by now _241105_) because the interactions with the [GaiaX Clearing Houses (GXDCH)](https://gaia-x.eu/gxdch/) have to be yet fully polished.  

The last step of the [deployment of a provider](README-provider.md#step-45-addition-of-the-service-route-to-the-apisix-without-security) left a [service accessible](https://fiwaredsc-provider.ita.es/ngsi-ld/v1/entities?type=Order) but without any authentication nor authorization implemented.

## Step 5.1-Addition of the service route to the Apisix with VC Authentication    
  To enable the apisix to play the PEP role, this step is adding a plugin to the NGSI-LD service `fiwaredsc-provider.ita.es/ngsi-ld/` route. The plugin will play the PEP (Policy Enforcment Point) role.  
     The `ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es` json contains a new plugins `openid-connect`, an authentication protocol based on the OAuth 2.0 that redirects NGSI-LD requests to the VCVerifier, as it implements the [OIDC4VP](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#request_scope), it will validate the authenticity of the VC presented. Actually, the VC has to be sent by the client embedded inside a VP ([Verifiable Presentation](https://wiki.iota.org/identity.rs/explanations/verifiable-presentations/)).

```json
      # https://fiwaredsc-provider.ita.es/ngsi-ld/...
      ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es='{
        "uri": "/ngsi-ld/*",
        "name": "service",
        "host": "fiwaredsc-provider.ita.es",
        "methods": ["GET", "POST", "PUT", "HEAD", "CONNECT", "OPTIONS", "PATCH", "DELETE"],
        "upstream": {
          "type": "roundrobin",
          "scheme": "http",
          "nodes": {
            "ds-scorpio.service.svc.cluster.local:9090": 1
          }
        },
        "plugins": {
          "proxy-rewrite": {
              "regex_uri": ["^/ngsi-ld/(.*)", "/ngsi-ld/$1"]
          },
          "openid-connect": {
            # https://apisix.apache.org/docs/apisix/plugins/openid-connect/
            "bearer_only": true
            "use_jwks": true
            "client_id": "hackathon-service"
            "client_secret": "unused"
            "ssl_verify": "false"
            "discovery": "http://verifier.provider.svc.cluster.local:3000/services/hackathon-service/.well-known/openid-configuration"    
          }
        }
      }'
```
    
  As the route already exists, it can be updated (you require its internal id) instead of just created as in the previous routes.  
  Review the manageAPI6Routes script or jupyter files to see how to retrieve it.
  Once retrieved, using the new ENV VAR `ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es` run the command:

    ```shell
    # Update the route
    ...
    ROUTE_ID=00000000000000000269
    curl -i -X PUT -k https://$IP_APISIXCONTROL:9180/apisix/admin/routes/$ROUTE_ID \
        -H "X-API-KEY:$ADMINTOKEN" \
        -d "$ROUTE_PROVIDER_SERVICE_fiwaredsc_provider_ita_es"
    ...
    ```
  Again, the same request made to get NGSI-LD data will show a `401 Authorization Required` error
  ```shell
    # Test the service
    curl https://fiwaredsc-provider.ita.es/ngsi-ld/v1/entities?type=Order
        <html>
        <head><title>401 Aufthorization Required</title></head>
        <body>
        <center><h1>401 Authorization Required</h1></center>
        <hr><center>openresty</center>
        <p><em>Powered by <a href="https://apisix.apache.org/">APISIX</a>.</em></p></body>
        </html>
  ```

  Requests to access the service will require from now on the possession of a valid JWT token.
  The OIDC conversation will require the proper VC to grant access to the service, VC that has to be embedded inside a ([Verifiable Presentation](https://wiki.iota.org/identity.rs/explanations/verifiable-presentations/)).  
  The OIDC conversation begins at the well known url of the service to be accessed (`https://fiwaredsc-provider.ita.es/.well-known/openid-configuration`). From there, the OIDC-Token endpoint is retrieved (`https://fiwaredsc-provider.ita.es/services/hackathon-service/token`) and the interaction following the rules set for the **_grant_type=vp_token_** to obtain an access token.
  
  The VC to be used is the one generated previously at the section [Issuance of  VCs through a M2M flow (Using API Rest calls)](README-consumer.md#issue-vcs-through-a-m2m-flow-using-api-rest-calls)

  The script [generateAccessTokenFromVC](../../scripts/generateVPToken.sh) will perform this conversation like in the following demo:

  ```shell
  scripts/generateAccessTokenFromVC.sh $VERIFIABLE_CREDENTIAL 
      INFO: EXECUTING SCRIPT [scripts/generateAccessTokenFromVC.sh]:
      VERBOSE=[true]
      TEST=[false]
      PAUSE=[false]
      VERIFIABLE_CREDENTIAL=eyJhbGciOi..WU8xuBWLXA
      OIDC_URL=https://fiwaredsc-provider.ita.es
      CERT_FOLDER=./.tmp/VPCerts
      PRIVATEKEY_FILE=private-key.pem
      PUBLICKEY_FILE=public-key.pem
      STOREPASSWORD_LENGTH=128
      ACCESSTOKEN_SCOPE=operator
      ---
      Generating Certificates to sign the Verifiable Presentation
      - Certificates to sign the DID generated at './.tmp/VPCerts' folder.
      - DID [did:key:zDnaeSz6xXkTik1dZ2Cw92UjGtMAc84knWJK4ioj1J9u8h5Uq] to sign the Verifiable Presentation generated
      ---
      - Generate a VerifiablePresentation, containing the Verifiable Credential:
              1- Setup the header:
      Header: eyJhb...
      ---
              2- Setup the payload:
      Payload: eyJpc3MiOiAiZGlk...
              3- Create the signature:
      Signature: MEUCIBdt...
              4- Combine them to generate the JWT:
      VP_JWT: eyJhbGciOiJFUz...
              5- The VP_JWT representation of the VP_JWT has to be Base64-encoded(no padding!) (This is not a JWT):
      VP_TOKEN=ZXlKaGJHY2lPaUpG...5hffIpsqqYAB8
      ---
      - Finally An access token is returned to be used to request the service (This is a JWT)
      export DATA_SERVICE_ACCESS_TOKEN=eyJhbGciOiJS...rc-L-_w
  ```



## Bottom line
The setup of the data space leaves a complete scenario enabling the customization defining _business, operational and organizational agreements among participants_ via the policy definitions.
Each participant has control over their data and services _stablishing the conditions of their access while facilitating data sharing agreements_