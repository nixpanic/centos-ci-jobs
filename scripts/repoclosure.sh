#!/bin/sh
#
# Verify that all dependencies are available in the standard repositories.
#
# Call `repoclosure` for the selected repository files, this needs to include
# some of the base repositories that contain all dependencies.
#

# the repository to verify, passed as environment argument
#REPO=gluster-4.1
if [ -z "${REPO}" ]
then
	echo "Missing REPO environment variable, exiting..."
	exit 1
fi

# default repos we depend on
REPOS='base updates extras'

# build the repoclosure command
REPOCLOSURE='repoclosure '
for _REPO in ${REPOS}
do
	REPOCLOSURE="${REPOCLOSURE} -r ${_REPO}"
done

# munge the REPO into a name yum understands
REPO_NAME="$(sed 's/[-\.]//g' <<< "${REPO}")"

# centos-release package that provides the .repo file
RELEASE_PKG="centos-release-$(sed 's/[-\.]//g' <<< "${REPO}")"

# now everything is setup, fail on any error and run verbose
set -e
set -x

# install the centos-release package
yum -y install ${RELEASE_PKG}

# install repoclosure
yum -y install yum-utils

# finally run repoclosure
${REPOCLOSURE} -r ${REPO_NAME}
