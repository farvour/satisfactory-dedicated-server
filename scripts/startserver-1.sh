#!/usr/bin/env bash
#
# Customized version of the original FactoryServer.sh. This script
# prevents any overwrites from the app updating (as indicated in the original
# script's instructions), and also uses appropriate variable replacements
# for dedicated world values from the environment of the running container.

set -e

# # Set sane defaults if needed.
# : ${VALHEIM_SERVER_NAME:="My Valheim Server"}
# : ${VALHEIM_SERVER_WORLD:="dedicated_world"}
# : ${VALHEIM_SERVER_PASSWORD:=""}
# : ${VALHEIM_SERVER_PUBLIC:="0"} # Private, unlisted by default.

# # Dedicated server requires a password.
# if [ -z "${VALHEIM_SERVER_PASSWORD}" ]; then
#     echo "Password is not set!"
#     exit 1
# fi

# # BepInEx-specific settings
# # NOTE: Do not edit unless you know what you are doing!
# ####
# export DOORSTOP_ENABLE=TRUE
# export DOORSTOP_INVOKE_DLL_PATH=./BepInEx/core/BepInEx.Preloader.dll
# export DOORSTOP_CORLIB_OVERRIDE_PATH=./unstripped_corlib

# export LD_LIBRARY_PATH="./doorstop_libs:$LD_LIBRARY_PATH"
# export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"

# # End BepInEx-specific settings

# export templdpath=$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
# export SteamAppId=892970

# echo "Starting server PRESS CTRL-C to exit"

# echo "Name: ${VALHEIM_SERVER_NAME}"
# echo "World: ${VALHEIM_SERVER_WORLD}"

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
