Include %occStatus

Class CI.TestRunner.Orchestrator [ Abstract ]
{

ClassMethod Orchestrate() As %Status
{
  set maybeNamespace = $System.Util.GetEnviron("CI_NS")

  new $namespace
  if maybeNamespace '= "" set $namespace = maybeNamespace

  $$$QuitOnError($System.OBJ.Load("/opt/ci/App/Installer.cls", "/compile"))
  $$$QuitOnError($System.OBJ.Load("/opt/ci/TestRunner/Runner.cls", "/compile"))

  write !
  zw ##class(CI.App.Installer).setup()
  write !

  set configuration = ##class(CI.TestRunner.Configuration).%New()
  set sc = ##class(CI.TestRunner.Runner).Run(configuration)

  if $$$ISERR(sc) {
    $$$QuitOnError(##class(CI.TestRunner.Logger).CreateErrorLog(sc))
  }

  $$$QuitOnError(##class(CI.TestRunner.Logger).CountAssertions())
  $$$QuitOnError(##class(CI.TestRunner.Logger).ParseTestFailures())

  return $$$OK
}

}
