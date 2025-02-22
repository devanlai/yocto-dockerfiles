#!/bin/bash
# Copyright (C) 2016-2021 Intel Corporation
# Copyright (C) 2022 Konsulko Group
#
# SPDX-License-Identifier: GPL-2.0-only
#
# This script is meant to be consumed by travis. It's very simple but running
# a loop in travis.yml isn't a great thing.
set -e

# Allow the user to specify another command to use for building such as podman
if [ "${ENGINE_CMD}" = "" ]; then
    ENGINE_CMD="docker"
fi

# If building for a nonstandard architecture, append the architecture to the name
TARGET_ARCH=$(echo "$TARGETPLATFORM" | cut -d'/' -f2)
if [ "${TARGET_ARCH}" = "${DEFAULT_ARCH}" ] || [ "${TARGET_ARCH}" = "" ]; then
    SUFFIX=""
else
    SUFFIX="-${TARGET_ARCH}"
fi

# Don't deploy on pull requests because it could just be junk code that won't
# get merged
if ([ "${GITHUB_EVENT_NAME}" = "push" ] || [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ] || [ "${GITHUB_EVENT_NAME}"  = "schedule" ])  && [ "${GITHUB_REF}" = "refs/heads/arm64" ]; then
    ${ENGINE_CMD} tag $REPO:$DISTRO_TO_BUILD-base$SUFFIX ghcr.io/$REPO:$DISTRO_TO_BUILD-base$SUFFIX
    ${ENGINE_CMD} tag $REPO:$DISTRO_TO_BUILD-builder$SUFFIX ghcr.io/$REPO:$DISTRO_TO_BUILD-builder$SUFFIX

    echo $GHCR_PASSWORD | ${ENGINE_CMD} login ghcr.io -u $GHCR_USERNAME --password-stdin
    ${ENGINE_CMD} push ghcr.io/$REPO:$DISTRO_TO_BUILD-base$SUFFIX
    ${ENGINE_CMD} push ghcr.io/$REPO:$DISTRO_TO_BUILD-builder$SUFFIX
fi
