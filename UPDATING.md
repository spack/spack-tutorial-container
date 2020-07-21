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
specifies that any time you push a branch matching the regular expression
`^rev-(.+)$`, DockerHub will build an image and use the matched group
(everything in the branch name following the `rev-`) to tag the image.  So if,
for example, you want a container to be tagged `sc20`, you would push a branch
to this repository named `rev-sc20`.

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

1. Either a) create a new mirror, or else b) clean out the existing one.  This
is required until the sync process between the mirror and the container build
cache is controlled by/limited to the spack environment in which it runs).  If
you choose to create a new mirror, the mirror url currently needs to be updated
in two locations: The `spack.yaml` and the DockerHub autobuild environment
variables (see [here](./DOCKERHUB_SETUP.md#configure-builds) for more
information).  If you choose to clean out the old mirror, just use the web
interface to remove the entire "build_cache" directory, and then there is
nothing else to change.

1. Create a new buildgroup in CDash to track the builds from the version to be
(done by editing the `spack.yaml` and changing the `build-group` property)

1. Update the `spack.yaml` file to adjust the set of packages, bootstrapped
compilers, etc as desired.

1. Create a PR on this repository and iterate on the `spack.yaml` until all
the packages build.

1. Merge the PR into master and/or tag the result using the tagging scheme
described in the section above.

## Items that may require updates as OS/Spack version change

Check what version of `gcc` gets installed by `apt-get` by default if you
don't specify a version.  That should be the compiler the tutorial picks
to install most packages.  Then an older `gcc` should be installed and used
to install zlib with the "custom" system compiler.  If either of those
compilers aren't in the image used to build the pipeline, they need to
be bootstrapped in the `spack.yaml`.  Then a newer `gcc` should also be
added to the `spack.yaml` and used for the demonstration of installing
a `gcc` with spack (and building all the packages with it in the subsequent
steps).  That compiler will need to be bootstrapped as well.

Check if `tcl` is still a 1-dependency package, if it's not, it should
be replaced with one.

Check the hash of: `spack spec zlib @1.2.8 cppflags=-O3`, that hash should
be used in the line that installs `tcl` with a specific `zlib` dependency.

Check the version of `clang` we get with `apt-get install clang`.  If it is
no longer clang-6.0.0, then update the version of clang we bootstrap
in the `spack.yaml` and the packages that built against clang to match.

Make sure to update the release branch of spack checked out in the
tutorial script.
