#!/bin/bash
################################################################################
#
# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

CURR_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

set -e

. "$CURR_DIR"/scripts/common.sh
. "$CURR_DIR"/scripts/product.sh
. "$CURR_DIR"/scripts/install_deps.sh
. "$CURR_DIR"/scripts/sync_src.sh
. "$CURR_DIR"/scripts/build.sh
. "$CURR_DIR"/scripts/clean.sh
. "$CURR_DIR"/scripts/install.sh

#######################################
# Print usages
#######################################
print_usage()
{
  echo -e "\n${FG_RED}Usage${FG_NONE}:
  ${FG_BOLD}./rdk.sh${FG_NONE} [product|sync-src|build|clean|install|uninstall|usage|version] [OPTION]"

  echo -e "\n${FG_RED}Options${FG_NONE}:
  ${FG_BLUE}product [product name]${FG_NONE}: select a product for build
  ${FG_BLUE}install-deps ${FG_NONE}: Install all package dependences
  ${FG_BLUE}sync-src [--force]${FG_NONE}: sync source code for selected packages
  ${FG_BLUE}build [--args ARGS]${FG_NONE}: build ros2 packages
  ${FG_BLUE}clean ${FG_NONE}: remove build|install folders.
  ${FG_BLUE}install${FG_NONE}: install generated ros2 to /opt/robot_devkit folder.
  ${FG_BLUE}uninstall${FG_NONE}: delete rdk_ws folder and uninstall generated ros2 from /opt/robot_devkit folder.
  ${FG_BLUE}usage${FG_NONE}: print this menu
  ${FG_BLUE}version${FG_NONE}: display current commit and date
  "
}


#######################################
# Check system version
#######################################
check_system_version()
{
  local system_ver
  if [[ -f /etc/lsb-release ]]; then
    system_ver=$( < /etc/lsb-release grep -i "DISTRIB_RELEASE" | cut -d "=" -f2)
    if [[ $system_ver != "18.04" ]] ;then
      echo -e "\n${FG_RED}Error${FG_NONE}:
      ${FG_BLUE}sorry, robot_devkit currently supports only Ubuntu 18.04${FG_NONE}
      "
      exit 1
    fi
  else
    echo -e "\n${FG_RED}Error${FG_BLUE}:
    ${FG_BLUE}sorry, robot_devkit currently supports olny ubuntu 18.04${FG_NONE}
    "
    exit 1
  fi
}

#######################################
# Main entry for this script
#######################################
main()
{
  # check system version
  check_system_version

  local cmd=$1
  if [ -z "$cmd" ]; then
    print_usage
    exit 0
  fi

  shift

  if [[ "${cmd}" = "install" ]] || [[ "${cmd}" = "uninstall" ]] || [[ "${cmd}" = "version" ]] && [[ "$*" ]]; then
    echo -e "\n${FG_RED}./rdk.sh: error${FG_NONE}:${FG_BLUE} '$cmd' unrecognized arguments${FG_NONE}:${FG_RED} '$*'${FG_NONE}"
    print_usage
    exit 1
  fi

  case $cmd in
    product)
      select_product "$@"
      ;;
    install-deps)
      install_deps "$@"
      ;;
    sync-src)
      sync_src "$@"
      ;;
    build)
      build "$@"
      ;;
    clean)
      clean "$@"
      ;;
    install)
      install_rdk
      ;;
    uninstall)
      uninstall_rdk
      ;;
    usage)
      print_usage
      ;;
    version)
      version
      ;;
    *)
      print_usage
      ;;
  esac
}

main "$@"
