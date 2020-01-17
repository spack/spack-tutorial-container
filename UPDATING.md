# Introduction

This document describes the container versioning scheme and the process for
updating the container.

# Steps

1. (optional) Use the shell script in the `keyhelp` directory to take a key
keychain and export both the public and private parts to files used in the
pipeline.  The `public.key` will be stored in the container so users can
verify the packages in the build cache.  The `pipeline.key` output file will
contain the text that should be copy/pasted into the CI environment variable
`SPACK_SIGNING_KEY` so pipeline jobs will be able to both sign and verify
packages.  This repo contains a script that can generate the needed products
from a keychain, given an export path and a key name.  From the root of this
repository, run:

    $ ./keyhelp/export_pipeline_key.sh ./docker "name-of-key-to-export"

The `public.key` can be committed to the repository and kept around for as
long as the signing key (private) will continue to be used to sign the
tutorial packages.

NOTE: the "name-of-key-to-export" should identify a key from the keychain
that does not require a passphrase, or it will not work in the pipeline
build jobs.

1. Create a new mirror (this is required until the sync process between the
mirror and the container build cache is controlled by/limited to the spack
environment in which it runs)

1. Create a new buildgroup in CDash to track the builds from the version to be
(done by editing the `spack.yaml` and changing the `build-group` property)

1. Update the set of packages, bootstrapped compilers, etc as desired

1. Create a PR on this repository and iterate on the `spack.yaml` until all
the packages build.

1. Merge the PR into master and tag the result, the tag name will later be
picked up by DockerHub and used to tag the container it builds from the repo
tag.