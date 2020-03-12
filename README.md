> WIP: This is a prototype and might not work as expected, but you are free to test and contribute.

# IRIS CI

Basically a way to run your unit tests in a way that continuous integration tools might like, including the GitHub Actions.

## Quickstart

1. Download the image from the registry:

```
docker pull rfns/iris-ci:0.4.0
```

2. Run the container (with the default settings)

```
docker run --rm --name ci -t -v /path/to/your/app:/opt/ci/app rfns/iris-ci
```

## Environment variables

There are three types of environment variables:

* Variables prefixed with `CI_{NAME}`are passed down as `name` to the installer manifest.
* Variables prefixed with `TESPARAM_{NAME}`are passed down as `NAME` to the unit test manager's UserFields property.
* `TEST_SUITE`and `TEST_CASE`to control where to locate and which test case to target.

If you don't specify the `TEST_SUITE` the `recursive` flag will be set.
So if you have a project with many classes, it might be interesting to at least define the `TEST_SUITE` due to performance concerns.

You can provide these variables by using a `.env` or by passing it directly to the container using the `-e` flag. You can read more about the `run` command and its flags from the official Docker [documentation.](https://docs.docker.com/engine/reference/commandline/run/).


## About the installer manifest

This image ships with a installer manifest that accepts the following additional envs:

* `CI_CSPAPP` is the name of the CSP web application that should be created.
* `CI_RESTAPP` is the name of the CSP web application that uses a REST interface.
* `CI_RESTDISPATCHCLASS` is the name of the class used to handle the requests for `CI_RESTAPP`.

Although it could prove to be useful, sometimes you might also want to have full control over the setup.
You can do so by mounting a volume that overwrites the file that resides on the path `/opt/ci/App/Installer.cls`.

