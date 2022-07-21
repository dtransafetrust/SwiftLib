#!/usr/bin/env bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#
# FILE NAME:
#   build-app.sh
#

set -o errexit;
set -o pipefail;

###############################################################################
# SUPPORT FUNCTIONS
###############################################################################

function log() {
    printf '%s\n' "$(date +'%Y-%m-%d %H:%M:%S'): ${1}";
};

function create_folder() {
    log ">>>>>>>>>> create_folder #folderPath: ${1}";

    log "creating folder: ${1} - begin.";
    mkdir -p ${1};
    log "creating folder: ${1} - done.";

    log "<<<<<<<<<< create_folder";
};

function clean_up() {
    log ">>>>>>>>>> clean_up #path: '${1}'";

    rm -rf ${1};

    log "<<<<<<<<<< clean_up";
};

function download_binary() {
    log ">>>>>>>>>> download_binary #output: '${1}' #url: '${2}'";

    wget -O "${1}" "${2}";

    log "<<<<<<<<<< download_binary";
}

function extract_binary() {
    log ">>>>>>>>>> extract_binary #source: '${1}' #destination-path: '${2}'";

    unzip "${1}" -d "${2}";

    log "<<<<<<<<<< extract_binary";
}

function go_to_folder() {
    log ">>>>>>>>>> go_to_folder #path: ${1}";

    log "Go to folder: '${1}' - begin.";
    cd ${1};
    log "Go to folder: '${1}' - done.";

    log "<<<<<<<<<< go_to_folder";
};

function copy_file() {
    log ">>>>>>>>>> copy_file #source: '${1}' #target: '${2}'";

    log "Copy file '${1}' to '${2}' - begin.";
    cp "${1}" "${2}";
    log "Copy file '${1}' to '${2}' - done.";

    log "<<<<<<<<<< copy_file";
}

function replace_content() {
    log ">>>>>>>>>> replace_content #file: '${1}' #string-to-replace: '${2}' #replaced-string: '${3}' #build-target: '${4}'";

    [[ "${4}" == "jenkins" ]] && sed -i "s/${2}/${3}/" "${1}";
    [[ "${4}" == "local" ]] && sed -i "" "s/${2}/${3}/" "${1}";

    log "<<<<<<<<<< replace_content";
};

function replace_string() {
    log ">>>>>>>>>> replace_substring #file: '${1}' #string-to-replace: '${2}' #replaced-string: '${3}' #build-target: '${4}'";

    gsed -i "s~\([a-z]*\)${2}*~${3}~g" "${1}";

    log "<<<<<<<<<< replace_substring";
};

###############################################################################
# BUSINESS FUNCTIONS
###############################################################################

function prepare_app_configuration() {
    log ">>>>>>>>>> prepare_app_configuration #current-path: '${1}' \
                                              #build-target: '${2}' \
                                              #project-version: '${3}' \
                                              #git-latest-hash: '${4}'";

    replace_string "${1}/Sample.xcodeproj/project.pbxproj" "(PROJECT_DIR)/../build" "(PROJECT_DIR)/../Frameworks/${3}/iPhoneOS" "${2}";
    replace_string "${1}/Sample.xcodeproj/project.pbxproj" "@executable_path/../build" "@executable_path/../Frameworks/${3}/iPhoneOS" "${2}";
    replace_string "${1}/Sample.xcodeproj/project.pbxproj" "(PROJECT_DIR)/../build" "(PROJECT_DIR)/../Frameworks/${3}/iPhoneOS" "${2}";
    replace_string "${1}/Sample.xcodeproj/project.pbxproj" \
                   "explicitFileType = wrapper.framework; path = SafetrustWalletDevelopmentKit.framework; sourceTree = BUILT_PRODUCTS_DIR;" \
                   "lastKnownFileType = wrapper.framework; name = SafetrustWalletDevelopmentKit.framework; path = ../../Frameworks/${3}/iPhoneOS/SafetrustWalletDevelopmentKit.framework; sourceTree = \"<group>\";" \
                   "${2}";
    replace_string "${1}/Sample.xcodeproj/project.pbxproj" \
                "path = ../build/SafetrustWallet.framework" \
                "path = ../Frameworks/${3}/iPhoneOS/SafetrustWallet.framework" \
                "${2}";
    replace_string "${1}/Sample.xcodeproj/project.pbxproj" \
                   "CURRENT_PROJECT_VERSION = .*;" \
                   "CURRENT_PROJECT_VERSION = ${3};" \
                   "${2}";

    log "<<<<<<<<<< prepare_app_configuration";
}

function assemble_app() {
    log ">>>>>>>>>> assemble_app #current-path: '${1}' #configuration: '${2}' #build-scheme: ${3}";

    local current_path="${1}";
    local configuration="${2}";
    local buildScheme="${3}";

    fastlane gym
    #xcodebuild -workspace ${current_path}/Sample.xcworkspace  -configuration ${configuration} -scheme ${buildScheme};
    log "<<<<<<<<<< assemble_app";
}

###############################################################################
# MAIN FUNCTION
###############################################################################

function main() {
    log ">>>>>>>>>>>>>>>>>>>> main #current-path: ${1} \
                                   #configuration: ${2} \
                                   #build-target: ${3} \
                                   #build-scheme: '${4}' \
                                   #project-version: '${5}' \
                                   #git-latest-hash: '${6}'";

    local configuration="${2}";
    local build_target="${3}";
    local project_version="${5}";
    local git_latest_hash="${6}";
    go_to_folder "${1}";
    local current_path=$(eval "echo $(PWD)");

    prepare_app_configuration "${current_path}" "${build_target}" "${project_version}" "${git_latest_hash}";

    go_to_folder "${current_path}";
    assemble_app "${current_path}" "${2}" "${4}";

    log "<<<<<<<<<<<<<<<<<<<< main";
    exit 0;
};

###############################################################################
# EXECUTION
###############################################################################

main "${1}" \
     "${2}" \
     "${3}" \
     "${4}" \
     "${5}" \
     "${6}";

#EOF
