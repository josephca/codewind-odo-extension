#!/usr/bin/env bash
###################################################################################
# Copyright (c) 2019 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
###################################################################################

# Define general variables
ODO_EXTENSION_DIR=/codewind-workspace/.extensions/codewind-odo-extension
ODO_CLI=$ODO_EXTENSION_DIR/bin/odo

# General setup
source /file-watcher/scripts/constants.sh
set -o pipefail
util=/file-watcher/scripts/util.sh

COMMAND=$1
shift 1

function odoCreate() {
	echo "- Creating odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$ODO_CLI create $COMPONENT_TYPE $COMPONENT_NAME |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
    if [ $? -eq 0 ]; then
		echo "- Successfully created odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	else
		echo "- Failed to create odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		exit 1
	fi
}

function odoPush() {
	echo "- Building and deploying odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$ODO_CLI push |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -eq 0 ]; then
		echo "- Successfully built and deployed odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	else
		echo "- Failed to build and deploy odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		exit 1
	fi
}

function odoUrl() {
	echo "- Creating url for odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	$ODO_CLI url create $COMPONENT_NAME |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	if [ $? -eq 0 ]; then
		echo "- Successfully created url for odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
	else
		echo "- Failed to create url for odo component: $COMPONENT_NAME" |& tee -a $ODO_BUILD_LOG $ODO_DEBUG_LOG
		exit 1
	fi
}

function odoLog() {
    echo "- Generating log for odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
	$ODO_CLI log $COMPONENT_NAME |& tee -a $ODO_DEBUG_LOG
	if [ $? -eq 0 ]; then
		echo "- Successfully generated log for odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
	else
		echo "- Failed to generate log for odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
		exit 1
	fi
}

function odoDelete() {
    echo "- Deleting odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
    if [ $($ODO_CLI list | awk '{print $2}' | tail -n +2 | grep $COMPONENT_NAME) == "$COMPONENT_NAME" ]; then
        $ODO_CLI delete $COMPONENT_NAME --all -f |& tee -a $ODO_DEBUG_LOG
	    if [ $? -eq 0 ]; then
		    echo "- Successfully deleted odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
	    else
		    echo "- Failed to delete odo component: $COMPONENT_NAME" |& tee -a $ODO_DEBUG_LOG
		    exit 1
	    fi
    else
        echo "- The odo component $COMPONENT_NAME did not exist" |& tee -a $ODO_DEBUG_LOG
    fi
}

if [ $COMMAND == "create" ]; then
    COMPONENT_TYPE=$1
    COMPONENT_NAME=$2
    ODO_BUILD_LOG=$3
    ODO_DEBUG_LOG=$4
    odoCreate
elif [ $COMMAND == "push" ]; then
    COMPONENT_NAME=$1
    ODO_BUILD_LOG=$2
    ODO_DEBUG_LOG=$3
    odoPush
elif [ $COMMAND == "url" ]; then
    COMPONENT_NAME=$1
    ODO_BUILD_LOG=$2
    ODO_DEBUG_LOG=$3
    odoUrl
elif [ $COMMAND == "log" ]; then
    COMPONENT_NAME=$1
    ODO_APP_LOG=$2
    ODO_DEBUG_LOG=$3
    odoLog
elif [ $COMMAND == "delete" ]; then
    COMPONENT_NAME=$1
    ODO_DEBUG_LOG=$2
    odoDelete
fi
