# Overview

This repository is used as a component in the automated building of the Spack tutorial containers.  However, it also serves to illustrate a custom workflow (based on spack ci/pipeline infrastructure) designed to assist in iteratively building a set of spack packages, pushing package binaries to a mirror, and then automatically building a Docker image containing the resulting binary packages.  The workflow proceeds as follows:

1. Developer makes changes to the spack stack (environment) in this repository, and pushes a branch against which a PR is created.  The changes could include changing the CDash build group so that builds will be tracked together.
2. Gitlab CI/CD notices the change and triggers a pipeline which builds the entire stack of packages, and reports a status check back to Github
3. Developer can make more changes and push to the PR branch as many times as necessary, and each time a pipeline will be triggered on Gitlab.
4. When the developer is satisfied with the stack/environment and all the packages are successfully built, the developer merges the PR into the master branch of this repo, and then tags the repository following a predefined tag format.
5. The creation of the tag triggers an automated DockerHub build which copies the binary packages (along with ancillary resources) into the container and publishes the resulting container.

## Moving parts

This document describes the pieces involved in this workflow and how those pieces fit together, including how the new spack automated pipeline workflow is used in the process.

This custom workflow involves this Github repository, a Gitlab "CI/CD only" repository (premium license needed for "CI/CD only" repository) with runners configured, an external spack mirror to hold the binaries (in our case hosted as an AWS S3 bucket), and a DockerHub repository for building the final container.

## Github repo (this repository)

This repository contains a spack environment with a set of packages to be built into a Docker container.  It also contains a `.gitlab-ci.yml` file to be used by a Gitlab CI/CD repository (for automated pipeline testing), as well as Docker resources needed to build both the pipeline package building container, as well as a final output container with all the binaries from spack environment.

The simple `.gitlab-ci.yml` file in this repo describes a single job which is used to generate the full workload of jobs for the pipeline (often referred to as the pre-ci phase).  Because the runner we have targeted with the `spack-kube` tag does not have the version of spack we need already installed, we first clone and activate the version we do need.  Also note how the command line arguments `--spack-repo` and `--spack-ref` are used to propagate that information to `spack ci generate ...`, so that build jobs are generated to use the same version of spack as used during the pre-ci phase.

## Gitlab CI/CD repo

Create a CI/CD only repository in Gitlab and link it to the Github repository.  Some things that may need to be configured include conditions under which pipelines should be run (PRs, push to PR branch, etc...) and other pipeline settings (clone strategy, job timeouts, and job variables).

When creating the CI/CD only repository, you can choose what kinds of events on the Github repository should run pipelines.

See the spack pipeline [documentation](https://github.com/scottwittenburg/spack/blob/add-spack-ci-command/lib/spack/docs/pipelines.rst#environment-variables-affecting-pipeline-operation) for more details on the job environment variables that may need to be set, but a brief summary of some common environment variables follows.

1. `SPACK_REPO` (optional) Useful if a custom spack should be cloned to generate and run the pipeline jobs
2. `SPACK_REF` (optional) Useful if a custom spack should be cloned to generate and run the pipeline jobs
3. `SPACK_SIGNING_KEY` Required to sign buildcache entries (package binaries) after they are built
4. `AWS_ACCESS_KEY_ID` (optional) Needed to authenticate to S3 mirror
5. `AWS_SECRET_ACCESS_KEY` (optional) Needed to authenticat to S3 mirror
6. `S3_ENDPOIT_URL` (optional) Needed if targeting an S3 mirror which is NOT hosted on AWS
7. `CDASH_AUTH_TOKEN` (optional) Needed if reporting build results to a CDash instance
8. `DOWNSTREAM_CI_REPO` Needed until Gitlab child pipelines are implemented.  This is the repo url where the generated workload should be pushed, and for many cases, pushing to the same repo is a workable approach.

Because we want to use a custom spack (one other than the runners may already have available), we add the `SPACK_REPO` and `SPACK_REF` environment variables listed above.  We then use those variables to clone spack in the pre-ci phase, as well as pass them along to the `spack ci generate` command so that custom spack will be cloned and activated as a part of the `before_script` of each generated pipeline job.

## Spack mirror

This workflow makes use of a public mirror hosted on AWS S3.  The automated pipeline pushes binaries to the mirror as packages are successfully built, and then the auto-build on DockerHub pulls those and copies them into the image for publishing.  To authenticate with the S3 bucket, authentication credentials should be stored in CI variables as described in the section above.

## DockerHub repository

The DockerHub repository is configured to automatically build a container from the `Dockerfile` and build context in the `docker/tutorial-image/` directory of this repository.  The build context also contains a custom build hook used by DockerHub to create the container in such a way that a few environment variables are made available as `--build-args` when the container is built.

The variables are `REMOTE_BUILDCACHE_URL` (publicly accessible mirror url where the binares were pushed by the Gitlab CI/CD pipeline), as well as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (needed to authenticate to the binary mirror, which is an S3 bucket).

