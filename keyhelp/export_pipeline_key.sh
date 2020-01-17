#!/bin/bash

# Default, no-argument behavior is to export all keys and write
# into the current directory.  Otherwise, 1) export path and 2) the
# name of the key can be specified, in that order.
#
#     $ ./export_pipeline_key.sh </path/to/output_files> <name of key to export>
#
# Key name can be omitted, or both arguments can be omitted, but don't provide
# only key name, as it will be treated as the output path.
#

EXPORT_PATH="$1"
EXPORT_KEY_NAME="$2"

if [ -z "${EXPORT_PATH}" ]; then
    EXPORT_PATH="./"
fi

# To put in container for users to verify signed packages
gpg2 --export \
    --armor "${EXPORT_KEY_NAME}" \
    > "${EXPORT_PATH}/public.key"

# Contents of output file "private.key" should be put in CI environment
# variable  SPACK_SIGNING_KEY, so pipeline jobs can import and use it
# for both signing and verifying packages.
(
    gpg2 --export --armor "${EXPORT_KEY_NAME}" \
 && gpg2 --export-secret-keys --armor "${EXPORT_KEY_NAME}"
) | base64 | tr -d '\n' > "${EXPORT_PATH}/private.key"

chmod 600 "${EXPORT_PATH}/private.key"
