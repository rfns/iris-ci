# Port Test Runner for IRIS

This repository contains a set of scripts to generate a Docker image that can be used to run unit test for qualified classes.

## Quickstart

1. Pull the image by running the command:

```sh
docker login -u your_gh_username -p your_gh_password
docker pull docker.pkg.github.com/rfns/iris-port-ci/iris-port-ci:latest
```

2. Run the image with a volume mounted to /opt/runner/app that links to your project:

```
docker run --name ci -t --rm --volume ~/projects/my-cache-project:/opt/runner/app rfns/iris-port-ci/iris-port-ci
```


 
