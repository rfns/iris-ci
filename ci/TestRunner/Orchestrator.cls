Include %occStatus

Class CI.TestRunner.Orchestrator
{

ClassMethod Orchestrate() As %Status
{
  try {
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/App/Installer.cls", "/compile"))
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/TestRunner/Runner.cls", "/compile"))

    $$$ThrowOnError(..GetEnvironmentVars(.vars, .envList))

    write !
    $$$ThrowOnError(##class(CI.App.Installer).setup(.vars))
    write !

    set configuration = ##class(CI.TestRunner.Configuration).%New(envList)
    $$$ThrowOnError(##class(CI.TestRunner.Runner).Run(configuration))

    set summary = ##class(CI.TestRunner.Logger).CreateSummaryFromFailures()

    if $$$ISERR(summary) {
      $$$ThrowOnError(##class(CI.TestRunner.Logger).CreateErrorLog(summary))
    }

    $$$ThrowOnError(##class(CI.TestRunner.Logger).RegisterAssertionStatistics())
  } catch ex {
    set status = ex.AsStatus()
    do ##class(CI.TestRunner.Logger).CreateErrorLog(status)
    do $System.Process.Terminate(, 1)
  }

  return $$$OK
}

ClassMethod GetEnvironmentVars(Output vars As %String = "", Output envs As %ArrayOfDataTypes = "") As %Status
{
  set envs = ##class(DotEnv.Parser).FromPath("/opt/ci")
  set name = ""

  if $isobject(envs) {
    for i=1:1:envs.Count() {
      set name = envs.Next(name)
      set value = envs.GetAt(name)
      set vars($$$lcase($replace(name, "CI_", ""))) = value
    }
  }

  return $$$OK
}

}
