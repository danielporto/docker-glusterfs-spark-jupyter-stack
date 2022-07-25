#!/bin/bash

help() {
    echo "Options: "
    echo " -i: set the docker image name. Default: pluribus"
    echo " -c: set the codebase path to use with the container." 
    echo "         Default: '$PWD/../..'" 
    echo " -d: set the data path where the experiment downloaded files must be. Default: emtpy"
    echo " -p: set the path where the plots must be generated. Default: empty"
    echo " -n: use default NAS configurations. Default: no"
    echo " -b: force build the container"
    echo " -a: build for arm architecture"

    echo "Usage: $0 < -i dockerimage >|< -c codepath >|< -d datapath >|< -p plotpath >|< -n use nas >|< -b >"
    exit;
}

DOCKERFILE="Dockerfile"

# get arguments
# https://stackoverflow.com/questions/22383336/option-requires-an-argument-error
# colon means that it requires an argument. flags wont require column (like -h and -b).
# while getopts "i:c:d:p:n:hba" option; do
#     case "${option}" in
#         i) DOCKERIMAGE=${OPTARG};;
#         c) CODEPATH=${OPTARG};;
#         d) DATAPATH=${OPTARG};;
#         p) PLOTPATH=${OPTARG};;
#         n) USENAS=${OPTARG};;
#         b) FORCEBUILD="true";;
#         h) help;;
#         a) DOCKERFILE="Dockerfile"
#     esac
# done

# # set defaults
# if [[ ! ${DOCKERIMAGE} ]]; then DOCKERIMAGE="kaioken_smart"; fi;
# if [[ ! ${CODEPATH} ]]; then CODEPATH="$PWD/../.."; fi;
# if [[ ! ${DATAPATH} ]]; then DATAPATH=""; fi;
# if [[ ! ${PLOTPATH} ]]; then PLOTPATH=""; fi;

# if using nas, set new defauls
# if [[ -n ${USENAS} ]]; then 
#     if [ -d "$HOME/nas" ]; then
#         echo "Using NAS. this option overides the codepath, datapath and plotpath"
#     else 
#         echo "NAS is not available exit."
#     fi;
    # CODEPATH="$HOME/nas/devel/sprint_eval"
    # DATAPATH="$HOME/nas/sprint_data"
    # PLOTPATH="$HOME/nas/sprint_plots"

    # echo "Using docker image: ${DOCKERIMAGE}"
    # echo "Using codebase: ${CODEPATH}"
    # echo "Using data dir: ${DATAPATH}"
    # echo "Using plot dir: ${PLOTPATH}"
# fi;

# building shortcuts
P95SCRIPTS="${CODEPATH}/playbooks/p95"
SMARTBBSCRIPTS="${CODEPATH}/playbooks/smartapps"
YCSBSCRIPTS="${CODEPATH}/playbooks/ycsb"
PLOTSCRIPTS="${CODEPATH}/plot"
OSSCRIPTS="${CODEPATH}/playbooks/osconfig"
SENSORSCRIPTS="${CODEPATH}/playbooks/sensorconfig"



# check if the container exists if not build it.
if ! grep --quiet $DOCKERIMAGE <<< "$(docker images)"; then docker build --file ./${DOCKERFILE} --build-arg UID=$(id -u)  . -t $DOCKERIMAGE 
fi;

if [[ ${FORCEBUILD} ]]; then docker build --file ./${DOCKERFILE} --build-arg UID=$(id -u)  . -t $DOCKERIMAGE ; echo "Build finished." ; exit; fi; 


MOUNT_CODEPATH="-v ${CODEPATH}:/code"
if [[ ! ${DATAPATH} ]] ; then MOUNT_DATAPATH=""; else MOUNT_DATAPATH="-v ${DATAPATH}:/data"; fi;
if [[ ! ${PLOTPATH} ]] ; then MOUNT_PLOTPATH=""; else MOUNT_PLOTPATH="-v ${PLOTPATH}:/plots"; fi;
if [[ ! ${USENAS} ]] ; then MOUNT_NASPATH=""; else MOUNT_NASPATH="-v ${HOME}/nas:/nas"; fi;

MOUNT_P95SCRIPTS="-v ${P95SCRIPTS}:/p95"
MOUNT_SMARTBBSCRIPTS="-v ${SMARTBBSCRIPTS}:/smartapps"
MOUNT_YCSBSCRIPTS="-v ${YCSBSCRIPTS}:/ycsbscripts"
MOUNT_PLOTSCRIPTS="-v ${PLOTSCRIPTS}:/plotscripts"
MOUNT_OSSCRIPTS="-v ${OSSCRIPTS}:/osscripts"
MOUNT_SENSORSCRIPTS="-v ${SENSORSCRIPTS}:/sensorscripts"
MOUNT_SSHPATH="-v ${HOME}/.ssh:/home/dporto/.ssh"

echo "Usage options: $0 -h"
docker run --name ${DOCKERIMAGE} --rm  $MOUNT_SSHPATH $MOUNT_CODEPATH $MOUNT_DATAPATH $MOUNT_PLOTPATH $MOUNT_YCSBSCRIPTS $MOUNT_SMARTBBSCRIPTS $MOUNT_PLOTSCRIPTS $MOUNT_OSSCRIPTS $MOUNT_SENSORSCRIPTS -it ${DOCKERIMAGE}
