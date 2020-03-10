Include %occStatus

Class CI.TestRunner.Orchestrator
{

ClassMethod Orchestrate() As %Status
{
  try {
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/App/Installer.cls", "/compile"))
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/TestRunner/Runner.cls", "/compile"))

    write !
    $$$ThrowOnError(##class(CI.App.Installer).setup())
    write !

    set configuration = ##class(CI.TestRunner.Configuration).%New()
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

}
