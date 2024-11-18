#!/bin/bash
hFileCommand consumer d -y
kRemoveRestart -y -v -fv secret consumer-keycloak
kRemoveRestart -y -v -fv secret consumer-postgresql
kRemoveRestart -y -v -fv pvc data-consumer-postgresql-0

hFileCommand consumer $@
