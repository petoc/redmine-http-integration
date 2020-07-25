#!/usr/bin/env bash

set -e

PROJECT_NAME="http_integration"

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${BASE_DIR}/_/build"
DIST_DIR="${BASE_DIR}/_/dist"

PROJECT_VERSION="$(git describe --tags)"
PROJECT_VERSION="${PROJECT_VERSION/v/}"

DIST_NAME="redmine-${PROJECT_NAME/_/-}-${PROJECT_VERSION}"
TARGET_DIR="${BUILD_DIR}/${PROJECT_NAME}"

cd "$BASE_DIR"
umask 022

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DIST_DIR"

cp -r "${BASE_DIR}/"{app,config,db,lib,init.rb,LICENSE,README.md} "${TARGET_DIR}"

sed -i "s|version 'master'|version '${PROJECT_VERSION}'|" "${TARGET_DIR}/init.rb"

find "${TARGET_DIR}" -exec touch -a -m -t "$(date +'%Y%m%d0000')" {} \;

cd "$BUILD_DIR"

tar -cf - "$PROJECT_NAME" | gzip -9 - > "${DIST_DIR}/${DIST_NAME}.tar.gz"
touch -a -m -t "$(date +'%Y%m%d0000')" "${DIST_DIR}/${DIST_NAME}.tar.gz"
