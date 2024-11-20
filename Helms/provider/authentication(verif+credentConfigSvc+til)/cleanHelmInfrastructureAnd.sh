#!/bin/bash
HELMNAME=authentication
hFileCommand $HELMNAME d -y
kRemoveRestart -y -v -fv secret mysql-secret
kRemoveRestart -y -v -fv pvc data-mysql-0

hFileCommand $HELMNAME $@
