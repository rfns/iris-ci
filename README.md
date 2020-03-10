> WIP: This is a prototype and might not work as expected, but you are free to test and contribute.

# IRIS CI

Basically a way to run your unit tests in a way that continuous integration tools might like, including the GitHub Actions.

## Quickstart

1. Download the image from the registry:

```
docker pull rfns/iris-ci
```

2. Run the container (with the default settings)

```
docker run --rm --name ci -t -e CI_NS="USER" -e CI_TESTSUITE="tests" --volume /path/to/your/app:/opt/ci/root --volume rfns/iris-ci
```

Notice the following pattern:

* `--rm` is used to kill the container from your list when the test suites are completed.
* `/opt/ci/root` is a required volume that indicates where your project is located.
* `CI_NS` is a required env var that indicates on which namespace the test suites should be run.
* `CI_TESTSUITE` is another env var that defines the path spec to determine where your test suites are. By default it's relative to the root folder. e.g. /opt/ci/root/tests where `test` is the value you provided to this env.

In addition there's also:

*  `CI_TESTMETHOD` to determine a single method to be tested.

3. About the installer manifest

This image ships with a installer manifest that accepts the following additional envs:

* `CI_APP` is the name of the CSP web application that should be created.
* `CI_RESTAPP` is the name of the CSP web application that uses a REST interface.
* `CI_RESTDISPATCHCLASS` is the name of the class used to handle the requests for `CI_RESTAPP`.

Although it could prove to be useful, sometimes you might also want to have full control over the setup.
You can do so by mounting a volume that overwrites the file that resides on the path `/opt/ci/App/Installer.cls`.

Checkout the default installer manifest class if you don't how to create one yet.

