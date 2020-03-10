> WIP: This is a prototype and might not work as expected, but you are free to test and contribute.

# IRIS CI

Basically a way to run your unit tests in a way that continuous integration tools might like, including the GitHub Actions.

## Quickstart

While we are in the testing (no pun intended) phase, this image must be built from this repo.

1. Clone this repo, go inside the folder and run the command:

```sh
docker build -t <tag> .
```

This will download the IRIS image that's required to build your container.

2. Run the following command to start your image:

```
docker run --rm --name ci --volume /the/path/for/a/project:/opt/ci/root --volume $PWD/ci/App/Installer.cls:/opt/ci/App/Installer.cls -e CI_NS="USER" rfns/ci
```

Simple eh? No, not quite. So let me break the basics for you:

* Notice that volume mounting to `/opt/ci/root`, that's where your sources should be located.
* By default this repo already includes a installer class that should work for non-complex projects. Otherwise you can mount a volume to that file with your own installer class. Just make sure to mount it to `/opt/ci/App/Installer.cls`.

Now it's time for the environment variables:

* `CI_APP` is the name of your web application. The default installer should be able to handle it.
* `CI_NS` is the namespace where your should be executed, since you're using a ephemeral storage, the USER namespace should suffice for most of your test cases, so you should change it only if your application requires it explicitly.
* `CI_RESTAPP` is the name of your web application, but now it's oriented for REST based APIs.
* `CI_RESTDISPATCHCLASS` is the name of the class that should handle your REST API application.
* `CI_TESTSUITE` is the relative path to the root mounted volume that helps the unit test manager to find your test suites.
* `CI_TESTMETHOD` is the name of the method that contains assertions. If you specify this, the unit test engine will execute the test only for this single method and exit.


