# IRIS CI

Basically a way to run your unit tests in a way that continuous integration tools might like, including the GitHub Actions.

## Quickstart

1. Download the image from the registry:

```
docker pull rfns/iris-ci:0.5.1
```

2. Run the container (with the default settings)

```
docker run --rm --name ci -t -v /path/to/your/app:/opt/ci/app rfns/iris-ci:0.5.1
```

## Environment variables

There's two ways to provide an environment variable:

* `-e VAR_NAME="var value"` while using `docker run`.
* By providing an extra volume for `docker run` like this: `-v /my/app/.env:/opt/ci/.env`.

> NOTE: In case a variable is defined in both formats, using the `-e` format takes precedence over using a `.env` file.

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

The `param` placeholder refers to the parameter names used by the [Security.Applications](https://docs.intersystems.com/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=Security) class when creating an new web application.

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

## Advanced control

You'll notice that by default the built-in Installer is designed for usage with unit test. But what if you wanted to another task like exporting a XML? Using the current classes: CI.Runner and App.Installer won't work.

This is where you need to overwrite one or both classes according to your needs.

You can overwrite them by providing a volume that mounts to your local implementation classes, e.g.

```
docker run --rm --name ci -t -v ~/Documents/iris-projects/myapp:/opt/ci/app -v ~/Documents/iris-projects/ci-xml/ci/App/Installer.cls:/opt/ci/App/Installer.cls -v ~/Documents/iris-projects/ci-xml/Runner.cls:/opt/ci/Runner.cls
```

### Regarding the implementation

While the `Installer.cls` provides you flexibility enough to create your own. The `Runner.cls` must be composed by two classmethods `Run` and `OnAfterRun`. Both must accept a configuration object provided by the `CI.Configuration` class.

The template for creating a runner class is as follows:

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
