# Introduction

This document describes the container versioning scheme and the process for
updating the container.

## Repo/Container versioning scheme

This section describes how and when DockerHub decides to automatically
rebuild the container, and how the built images are tagged.

There are two build rules (see this [section](./DOCKERHUB_SETUP.md#configure-builds)
for more info) governing when DockerHub will rebuild the container.  The
first specifies that any time you push to the `master` branch on this repo,
DockerHub will build an image and tag it with `latest`.  The second build rull
specifies that any time you push a tag matching the regular expression
`^rev-(.+)$`, DockerHub will build an image and use the matched group
(everything in the tag following the `rev-`) to tag the image.  So if, for
example, you want a container to be tagged `sc20`, you would tag this
repository `rev-sc20` and push it.

## Steps to build an updated container

1. (optional) Use the shell script in the `keyhelp` directory to take a key
keychain and export both the public and private parts to files used in the
pipeline.  The `public.key` will be stored in the container so users can
verify the packages in the build cache.  The `pipeline.key` output file will
contain the text that should be copy/pasted into the CI environment variable
`SPACK_SIGNING_KEY` so pipeline jobs will be able to both sign and verify
packages.  The `export_pipeline_key.sh` shell script can generate the needed
products from a keychain, given an export path and a key name.  The generated
`public.key` can be committed to the repository and kept around for as long as
the signing key (private) will continue to be used to sign the tutorial
packages.  Make sure to pick a key (by providing it's name) that does not
require a passphrase, or it will not work in the pipeline build jobs.  To use
the helper script, run the following command from the root of the repository:

    $ ./keyhelp/export_pipeline_key.sh ./docker "name-of-key-to-export"

1. Create a new mirror (this is required until the sync process between the
mirror and the container build cache is controlled by/limited to the spack
environment in which it runs).  The mirror url currently needs to be updated
in two locations: The `spack.yaml` and the DockerHub autobuild environment
variables (see [here](./DOCKERHUB_SETUP.md#configure-builds) for more
information).

1. Create a new buildgroup in CDash to track the builds from the version to be
(done by editing the `spack.yaml` and changing the `build-group` property)

1. Update the `spack.yaml` file to adjust the set of packages, bootstrapped
compilers, etc as desired.

1. Create a PR on this repository and iterate on the `spack.yaml` until all
the packages build.

1. Merge the PR into master and/or tag the result using the tagging scheme
described in the section above.
