#!/bin/bash
# git clone tools
DEVTOOLS_GH_HTTPS="https://github.com/cgonzalezITA/devopsTools.git"
git clone $DEVTOOLS_GH_HTTPS

# add exec permissions
DEVOPTOOLSFOLDER=devopsTools
find $DEVOPTOOLSFOLDER -name "*.sh" -type f -exec chmod +x {} +

# Save the folder in which devopsTools have been installed

# To use aliases
vi ~/.bash_aliases  
# Remember to customize the _TOOLSFOLDER env var.
export _TOOLSFOLDER="<fullPathToYourDevopsTools_folder>" 
alias _fGetFile='$_TOOLSFOLDER/fTools/_fGetFile.sh'
alias gPushAll='$_TOOLSFOLDER/gTools/gPushAll.sh'
alias gFreeze='$_TOOLSFOLDER/gTools/gFreeze.sh'
alias gCommit='$_TOOLSFOLDER/gTools/gCommit.sh'
alias gInfo='$_TOOLSFOLDER/gTools/gInfo.sh'
alias _dGetContainers='$_TOOLSFOLDER/dTools/_dGetContainers.sh'
alias dLogs='$_TOOLSFOLDER/dTools/dLogs.sh'
alias dCompose='$_TOOLSFOLDER/dTools/dCompose.sh'
alias dExec='$_TOOLSFOLDER/dTools/dExec.sh'
alias dGet='$_TOOLSFOLDER/dTools/dGet.sh'
alias dInspect='$_TOOLSFOLDER/dTools/dInspect.sh'
alias dRemove='$_TOOLSFOLDER/dTools/dRemove.sh'
alias kSecret-show='$_TOOLSFOLDER/kTools/kSecret-show.sh'
alias kExec='$_TOOLSFOLDER/kTools/kExec.sh'
alias kGet='$_TOOLSFOLDER/kTools/kGet.sh'
alias kFileCommand='$_TOOLSFOLDER/kTools/kFileCommand.sh'
alias _kGetNamespace='$_TOOLSFOLDER/kTools/_kGetNamespace.sh'
alias kSecret-create4Domain='$_TOOLSFOLDER/kTools/kSecret-create4Domain.sh'
alias kDescribe='$_TOOLSFOLDER/kTools/kDescribe.sh'
alias kLogs='$_TOOLSFOLDER/kTools/kLogs.sh'
alias _kGetArtifact='$_TOOLSFOLDER/kTools/_kGetArtifact.sh'
alias kSecret-createGeneric='$_TOOLSFOLDER/kTools/kSecret-createGeneric.sh'
alias kRemoveRestart='$_TOOLSFOLDER/kTools/kRemoveRestart.sh'
alias hFileCommand='$_TOOLSFOLDER/hTools/hFileCommand.sh'
#install yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O ./yq && chmod +x ./yq && sudo mv ./yq /usr/bin

##############################3
# Install the DSFiware-hackathon
DSFIWAREHOL_GH_HTTPS="https://github.com/cgonzalezITA/DSFiware-hackathon.git"
git clone $DSFIWAREHOL_GH_HTTPS 

# Launch the VSCode. This will open a new VSCode instance having the folder as the base folder 
code DSFiware-hackathon
# From here, open a new terminal and continue

# step01
# Create tls secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout Helms/apisix/certs/tls-wildcard.key -out Helms/apisix/certs/tls-wildcard.crt -subj "/CN=*.local"
kubectl create secret tls wildcardlocal-tls -n apisix --key Helms/apisix/certs/tls-wildcard.key --cert Helms/apisix/certs/tls-wildcard.crt

# Install the apisix
git checkout step01
export DEF_KTOOLS_NAMESPACE=apisix
hFileCommand apisix -y -b
# Add the route of dns . Your ip=$(hostname -I)
# eg. 193.143.225.86  fiwaredsc-consumer.local
vi /etc/hosts
# The curl should work
curl -k https://fiwaredsc-consumer.local


# step02
hFileCommand apisix r -y
# Populating the apisix helm chart takes a while (3/4 mins on my microk8s cluster)
kGet -w
# The curl should work
curl -k https://fiwaredsc-consumer.local

# step03
hFileCommand apisix -r -y
# Add the route of dns to your Windows host file (C:\Windows\System32\drivers\etc\hosts as admin) or linux (/etc/hosts as sudo). Your ip=$(hostname -I)
# eg. 193.143.225.86  fiwaredsc-api6dashboard.local
sudo vi /etc/hosts

# Navigate to url from a browser
https://fiwaredsc-api6dashboard.local
#Use this password
password=$(kSecret-show dashboard-secrets -f apisix-dashboard-secret -v)


# step04
# ? Upgrade the helm to redeploy the echo service
? hFileCommand apisix u -y

# Deploy via API the route https://fiwaredsc-consumer.local
 . Helms/apisix/manageAPI6Routes.sh 
 
# phase02
git checkout phase02
# Deploy the trust-anchor
hFileCommand trustAnchor -b
# Upgrade the apisix to manage the fiwaredsc-trustanchor.local dns
hFileCommand apisix u -y
# The deployment could take around 2/3 minutes
. Helms/apisix/manageAPI6Routes.sh
# test within the cluster
kExec utils -- curl http://tir:8080/v4/issuers

# Add the route of dns to your Windows host file (C:\Windows\System32\drivers\etc\hosts as admin) or linux (/etc/hosts as sudo). Your ip=$(hostname -I)
# eg. 193.143.225.86  fiwaredsc-trustanchor.local
sudo vi /etc/hosts

# test outside the cluster
# curl -k https://fiwaredsc-consumer.local/hello
curl -k https://fiwaredsc-trustanchor.local/v4/issuers
