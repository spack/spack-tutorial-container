# DockerHub Automated Build Setup

This document describes how to set up automated DockerHub container builds
to build, tag, and push a Docker container with the contents of the binary
mirror populated by the Gitlab pipeline.

DockerHub provides information on autobuilds [here](https://docs.docker.com/docker-hub/builds/).

In order to set up the automated builds, you just need to link your DockerHub
repository to your source code repository on GitHub then configure some build
rules telling DockerHub what source code repo actions should trigger builds
and how the resulting images should be tagged.  These steps are described in
more detail below.

## Link your DockerHub repo to your GitHub repo

Navigate to your repository on DockerHub and login.  Then click on the `Builds`
tab and choose "Link to GitHub".

<kbd><img src="./images/autobuild-link-to-github.png" alt="DockerHub link to GitHub" title="DockerHub link to GitHub" /></kbd>

Now you have a chance to choose your organization and repository.

<kbd><img src="./images/autobuild-select-org.png" alt="Select Org and Repo" title="Select Org and Repo" /></kbd>

In our case, we disable auto testing and repository links, but you may want
those turned on for your automated builds.  You can more more about auto
tests [here](https://docs.docker.com/docker-hub/builds/automated-testing/).
Repository links allow you to trigger builds when your base image changes,
but only for non-official images.

<kbd><img src="./images/no-autotest.png" alt="Disable AutoTest" title="Disable AutoTest" /></kbd>

## Configure builds

Configuring some autobuilds is a matter of adding a build rule for each kind of
event you want to trigger a build, and in our case, setting up some environment
variables you want to be available to the build process as `--build-arg` cli
args.

<kbd><img src="./images/autobuild-full-config-edited.png" alt="Full AutoBuild Config" title="Full AutoBuild Config" /></kbd>

In the screenshot above, you can see we have set up two build rules.  The first
will trigger a build whenever we push to the `master` branch on our linked
GitHub repository.  The resulting Docker image will simply be tagged `latest`.
We have configured anoher build to be triggered upon certain tags.  Any tag
that starts with `rev-` will be noticed and autobuilt.  Anything in the tag
string after the `rev-`, will be captured and used as the image tag.  For example
if you wish your resulting container to be tagged `sc19`, you would tag the repo
`rev-sc19`.

Note also in the screenshot above we have specified the location of the Dockerfile
and build context, as well as some environment variables.  You can see how the
environment variables are used by looking at the `docker/hooks/build` file in this
repo, where we issue a `docker build ...` command to make use of them.
