#!/usr/bin/env nix-shell
# shellcheck shell=bash
# Bash 3 compatible for Darwin

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Version of corretto from
# https://github.com/corretto/corretto-21/releases/
VERSION=$1

if [ -z "${VERSION}" ] || [ $# -ne 1 ]; then
  echo >&2 "usage: ./update.sh corretto21-version"
  exit 1
fi

# An array of plugin names. The respective repository inside Pulumi's
# Github organization is called pulumi-$name by convention.

declare -a corretto_repos
corretto_repos=(
  "corretto-21"
)

# Contains latest release ${VERSION} from
# https://github.com/corretto/${NAME}/releases

# Dynamically builds the plugin array, using the GitHub API for getting the
# latest version.

function genMainSrc() {
  local url="https://corretto.aws/downloads/resources/${VERSION}/amazon-corretto-${VERSION}-${1}-${2}.tar.gz"
  local sha256
  sha256=$(nix-prefetch-url "$url")
  echo "      {"
  echo "        url = \"${url}\";"
  echo "        sha256 = \"$sha256\";"
  echo "      }"
}

{
  cat << EOF
# DO NOT EDIT! This file is generated automatically by update.sh
{ }:
{
  version = "${VERSION}";
  correttoPkgs = {
EOF

  echo "    x86_64-linux = ["
  genMainSrc "linux" "x64"
  echo "    ];"

  echo "    x86_64-darwin = ["
  genMainSrc "macosx" "x64"
  echo "    ];"

  echo "    aarch64-linux = ["
  genMainSrc "linux" "aarch64"
  echo "    ];"

  echo "    aarch64-darwin = ["
  genMainSrc "macosx" "aarch64"
  echo "    ];"

  echo "  };"
  echo "}"

} > "${SCRIPT_DIR}/data.nix"
