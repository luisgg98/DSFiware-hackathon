#!/bin/bash
# Script based on steps described on https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD
############################
## Variable Initialization #
############################
SCRIPTNAME=$BASH_SOURCE
if [ "$0" == "$BASH_SOURCE" ]; then CALLMODE="executed"; else CALLMODE="sourced"; fi
BASEDIR=$(dirname "$SCRIPTNAME")

VERBOSE=true
STOP=false
# \t-i   | --info: Info of the given parameters \n\
INFO=false
#############################
## Functions               ##
#############################

URL_VCISSUER=https://fdsc-consumer-keycloak.ita.es/realms/test-realm
ADMIN_CLI=admin-cli
USER_01=test-user
USER_01_PASSWORD=test
CREDENTIAL_IDENTIFIER=user-credential

function help() {
    HELP=""
    if test "$#" -ge 1; then
        HELP=$1
    fi
    HELP="$HELP\nHELP: USAGE: $SCRIPTNAME <optional and mandatory parameters>] \n\
            \t-v   | --verbose: Does not show verbose info\n\
            \t-s   | --stop: Stops after each command is run\n\
            \t-h   | --help: Prints help\n\
            \t-i   | --info: Info of the given parameters \n\
            \t-vci | --vcIssuer: VerifiableCredential issuer (eg. http://keycloak-consumer.127.0.0.1.nip.io:8080) \n\
            \t-u   | --user: User to use to retrieve its <credentialType>\n\
            \t-p   | --password: User's password \n\
            \t-ct  | --credentialType: Credential to be embedded into the generated Verifiable Credential (e.g. user-credential)"
    echo $HELP
}
function runCommand() { #CMD, [#Message]
    echo > /dev/tty;
    FORMAT="runCommand <CMD> [<Debug message 2 be printed out>]"
    if test "$#" -lt 1; then
        echo -e "Error: Missing <CMD>:\n\t$FORMAT" > /dev/tty;
        [ "$CALLMODE" == "executed" ] && exit -1 || return -1;
    fi
    CMD=$1; shift;
    MSG=""
    if test "$#" -ge 1; then
        MSG=$1; shift;
    fi

    [ "$STOP" = true ] && read -p "Press a key to continue" || sleep 1;
    [ "$VERBOSE" = true ] && echo -e $MSG > /dev/tty;
    [ "$VERBOSE" = true ] && echo -e "Running command [$CMD]" > /dev/tty;
    VAR=$(eval $CMD)
    RC=$?
    if test "$RC" -ne 0; then
        echo "ERROR [$RC] running command [$CMD]" > /dev/tty; 
    else 
        echo $VAR
        return 0
    fi
}



##############################
## Main code                ##
##############################
# getopts arguments
while true; do
    case "$1" in
        -s | --stop ) 
            STOP=true; shift ;;
        -v | --verbose ) 
            VERBOSE=false; shift ;;
        -h | --help ) 
            echo -e $(help);
            [ "$CALLMODE" == "executed" ] && exit -1 || return -1;;
        -vci | --vcIssuer ) 
            URL_VCISSUER=$2;
            shift ; shift ;;
        -u | --user )
            USER_01=$2;
            shift ; shift ;;
        -p | --password )
            USER_01_PASSWORD=$2;
            shift ; shift ;;
        -i | --info )
            INFO=true;
            shift ;;
        -ct | --credentialType )
            CREDENTIAL_IDENTIFIER=$2;
            shift ; shift ;;
        * ) 
            if [[ $1 == -* ]]; then
                echo -e $(help "ERROR: Unknown parameter [$1]");
                [ "$CALLMODE" == "executed" ] && exit -1 || return -1;
            fi
            break ;;
    esac
done

###########
# Main flow
###########
if [ "$INFO" = true ]; then
    echo -e $(help);
fi

if [ "$VERBOSE" = true ]; then
    echo "INFO: EXECUTING SCRIPT [$SCRIPTNAME]:"
    echo "VERBOSE=[$VERBOSE]"
    echo "PAUSE=[$STOP]"
    echo "URL_VCISSUER=[$URL_VCISSUER]"
    echo "ADMIN_CLI=[$ADMIN_CLI]"
    echo "USER_01=[$USER_01]"
    echo "USER_01_PASSWORD=[$USER_01_PASSWORD]"
    echo "CREDENTIAL_IDENTIFIER=[$CREDENTIAL_IDENTIFIER]"
    echo "---"
fi

if [ "$INFO" = true ]; then
    [ "$CALLMODE" == "executed" ] && exit -1 || return -1;
fi
    

echo "Phase 1- Retrieve an existing a Verifiable Credential (VC) from a VCIssuer (Keycloak in this use case)"

MSG="---\n1.1- Get the URL from where to retrieve the Token to access the VC"
CMD="curl -s -X GET $URL_VCISSUER/.well-known/openid-configuration | jq '.token_endpoint' -r"
URL_VCISSUER_TOKEN=$(runCommand "$CMD" "$MSG")
echo -e "\nURL_VCISSUER_TOKEN=$URL_VCISSUER_TOKEN"

MSG="---\n1.2- Get Token to access the VC"
CMD="curl -s -X POST \"$URL_VCISSUER_TOKEN\" \
      --header 'Accept: */*' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data grant_type=password \
      --data client_id=$ADMIN_CLI \
      --data username=$USER_01 \
      --data password=$USER_01_PASSWORD | jq '.access_token' -r;"
ACCESS_TOKEN=$(runCommand "$CMD" "$MSG")
echo -e "\nACCESS_TOKEN=$ACCESS_TOKEN"

URL_CREDENTIAL_OFFER="$URL_VCISSUER/protocol/oid4vc/credential-offer-uri"
MSG="---\n1.3- Gets a credential offer uri, using the retrieved AccessToken"
CMD="curl -s -X GET \"$URL_CREDENTIAL_OFFER?credential_configuration_id=$CREDENTIAL_IDENTIFIER\" \
    --header \"Authorization: Bearer ${ACCESS_TOKEN}\" | jq '\"\(.issuer)\(.nonce)\"' -r;"
OFFER_URI=$(runCommand "$CMD" "$MSG")
echo -e "\nOFFER_URI=$OFFER_URI"

MSG="---\n1.4- Use the offer uri(e.g. the issuer and nonce fields), to retrieve the actual offer:"
CMD="curl -s -X GET ${OFFER_URI} \
            --header \"Authorization: Bearer ${ACCESS_TOKEN}\" | jq '.grants.\"urn:ietf:params:oauth:grant-type:pre-authorized_code\".\"pre-authorized_code\"' -r;"
export PRE_AUTHORIZED_CODE=$(runCommand "$CMD" "$MSG")
echo -e "\nPRE_AUTHORIZED_CODE=$PRE_AUTHORIZED_CODE"

MSG="---\n1.5- Uses the pre-authorized code from the offer to get a credential AccessToken at the authorization server"
CMD="curl -s -X POST $URL_VCISSUER_TOKEN \
      --header 'Accept: */*' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
      --data pre-authorized_code=${PRE_AUTHORIZED_CODE} \
      --data code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r;"
export CREDENTIAL_ACCESS_TOKEN=$(runCommand "$CMD" "$MSG")
echo -e "\nCREDENTIAL_ACCESS_TOKEN=$CREDENTIAL_ACCESS_TOKEN"

URL_CREDENTIAL_ENDPOINT="$URL_VCISSUER/protocol/oid4vc/credential"
MSG="---\n1.6- Finally Use the returned access token to get the actual credential"
CMD="curl -s -X POST \"$URL_CREDENTIAL_ENDPOINT\" \
      --header 'Accept: */*' \
      --header 'Content-Type: application/json' \
      --header \"Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}\" \
  --data \"{\\\"credential_identifier\\\":\\\"$CREDENTIAL_IDENTIFIER\\\", \\\"format\\\":\\\"jwt_vc\\\"}\" | jq '.credential' -r;"
export VERIFIABLE_CREDENTIAL=$(runCommand "$CMD" "$MSG")
echo -e "\n*****\nexport VERIFIABLE_CREDENTIAL=$VERIFIABLE_CREDENTIAL"