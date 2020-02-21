# Port Test Runner for IRIS

This repository contains a set of scripts to generate a Docker image that can be used to run unit test for qualified classes.

## Quickstart

1. Pull the image by running the command:

```sh
docker pull docker.pkg.github.com/rfns/test-runner/port-test-runner:latest
```

2. Run the image with a volume mounted to /opt/runner/app that links to your project:

```
docker run --name test-runner -t --rm --volume ~/projects/my-cache-project:/opt/runner/app rfns/test-runner/port-test-runner
```


