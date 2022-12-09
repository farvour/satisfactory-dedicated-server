#!/usr/bin/env bash
#
# Customized version of the original FactoryServer.sh. This script
# prevents any overwrites from the app updating (as indicated in the original
# script's instructions), and also uses appropriate variable replacements
# for dedicated world values from the environment of the running container.

set -e

SERVER_ARGS=(
	"-MultiHome=0.0.0.0"
	"-log"
	"-unattended"
)

set -x

UE4_TRUE_SCRIPT_NAME=$(echo \"$0\" | xargs readlink -f)
UE4_PROJECT_ROOT=$(dirname "$UE4_TRUE_SCRIPT_NAME")

chmod +x "$UE4_PROJECT_ROOT/Engine/Binaries/Linux/UE4Server-Linux-Shipping"

"$UE4_PROJECT_ROOT/Engine/Binaries/Linux/UE4Server-Linux-Shipping" \
	FactoryGame \
	${SERVER_ARGS[@]}
