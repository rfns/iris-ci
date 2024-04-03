# IRIS CI

Basically a way to run your ~~unit tests~~ runners in a way that continuous integration tools might like, including the GitHub Actions.

## Quickstart

Assuming that you have a `tests` folder with all your tests. Map the volume to the repo that contains it and [Port](https://github.com/rfns/port) will automatically your cls folder.

If your cls files are inside a `src` folder, add that as part of the local path as well. e.g: `-v $PWD/<your_repo>/src:/opt/ci/app`

```sh
docker run -t --rm --name ci \
-e TEST_SUITE="tests" \
-v $PWD/<you_repo>:/opt/ci/app ghcr.io/rfns/iris-ci/iris-ci:v0.6.3
```

## Environment variables

There's two ways to provide an environment variable:

* `-e VAR_NAME="var value"` while using `docker run`.
* By providing an extra volume for `docker run` like this: `-v /my/app/.env:/opt/ci/.env`.

> NOTE: In case a variable is defined in both formats, using the `-e` format takes precedence over `.env` files.

## Types of environment variables

* Variables prefixed with `CI_{NAME}` are passed down as `name` to the installer manifest.
* Variables prefixed with `TESPARAM_{NAME}`are passed down as `NAME` to the unit test manager's UserFields property.
* `TEST_SUITE`and `TEST_CASE` to control where to locate and which test case to target.

If you don't specify the `TEST_CASE` the `recursive` flag will be set.

So if you have a project with many classes, it might be interesting to at least define the `TEST_SUITE` and reduce the search scope due to performance concerns.

## Using the default installer manifest for unit tests

This image ships with a installer manifest that uses two prefixes in order to configure and create web applications:

* `CI_CSPAPP_{param}` is related to envs that can be used to configure CSP application.
* `CI_RESTAPP_{param}` same as as `CI_CSPAPP` but allow providing configurations related to creating a REST-based application.

The `param` placeholder refers to the property names used by the [Security.Applications](https://docs.intersystems.com/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=Security).
Usage example:

To create a CSP application named `csp/myapp`:

```
CI_CSPAPP_NAME="/csp/myapp"
CI_CSPAPP_PATH="/InterSystems/cache/csp/myapp"
```

To create a REST application named `/api/myapp`:

```
CI_RESTAPP_NAME="/api/myapp"
CI_RESTAPP_DISPATCHCLASS="API.MyApp"
```

Remember that additional parameters can be provided. Check the list below from the current installer implementation:

```objectscript
set params("AuthEnabled") = authMethods
set params("AutoCompile") = 1
set params("CSPZENEnabled") = 1
set params("CookiePath") = cookiePath
set params("DeepSeeEnabled") = 1
set params("Description") = ""
set params("DispatchClass") = dispatchClass
set params("Enabled") = 1
set params("InbndWebServicesEnabled") = 1
set params("IsNameSpaceDefault") = $case(dispatchClass, "": 1, : 0)
set params("LockCSPName") = 1
set params("MatchRoles") = roles
set params("NameSpace") = namespace
set params("Path") = directory
set params("Recurse") = recurse
set params("iKnowEnabled") = 1
set params("UseCookies") = 2
```

Note that some classes have default values while others have them hardcoded. This is because you mostly wouldn't care about those parameters while running the instance inside a CI environment.

### Implementing your own runner

While the `Installer.cls` provides you flexibility enough to create your own setup, the `Runner.cls` must be composed by two classmethods `Run` and `OnAfterRun`, both must accept a configuration object provided by the `CI.Configuration` class.
You can use `configuration.GetEnv("YOUR_ENV_NAME")` to consume environment variables and change your runner's behavior. _iris-ci_ already includes a [runner](https://github.com/rfns/iris-ci/blob/master/ci/Runner.cls) for running tests, but despite `ci` assumption, you can also use this tool as a `cd` companion. Check [iris-ci-xml](https://github.com/rfns/iris-ci-xml) to see an example of a runner that generates a project XML artifact.

The template for creating a runner class follows the format below:

```objectscript
Class CI.Runner
{

ClassMethod Run(configuration As CI.Configuration) As %Status
{
  return $$$OK
}

ClassMethod OnAfterRun(configuration As CI.Configuration) As %Status
{
  return $$$OK
}

}
```

### CONTRIBUTING

Although this project _works on my machine_™, you might still find bugs along the road or have good ideas. You're encouraged to either open a PR or issue. Don't be afraid!
