Class CI.Runner
{

ClassMethod Run(configuration As CI.Configuration) As %Status
{
  new $namespace

  set environmentNS = configuration.Envs.GetAt("CI_NAMESPACE")
  set $namespace = $get(environmentNS, $namespace)

  merge params = configuration.TestParameters

  #define NULL $s($$$isWINDOWS : "//./nul", 1: "/dev/null")

  set ^UnitTestRoot = "/opt/ci/app"
  set flags = "/"_configuration.RecurseFlag_"/run/noload/nodelete/nodisplay"
  set testSpec = configuration.TestSuite_":"_configuration.TestCase

  write "Running test suites from: "_^UnitTestRoot_"."
  write !, "Flags: "_flags
  write !, "Spec: "_$select(testSpec = ":" : " none", 1: testSpec)

  write !!, "The test execution summary will be displayed below. Please standby ..."

  set io = $io

  open $$$NULL
  use $$$NULL

  set sc = ##class(%UnitTest.Manager).RunTest(testSpec, flags, .params)

  use io
  close $$$NULL

  return sc
}

ClassMethod OnAfterRun(configuration As CI.Configuration) As %Status
{
  return ..HandleUnitTestFeedback()
}

ClassMethod HandleUnitTestFeedback() As %Status [ Private ]
{
  $$$ThrowOnError(##class(CI.Logger).CreateSummaryFromFailures(.summary))
  $$$ThrowOnError(##class(CI.Logger).CreateAssertionStatistics())

  if summary '= "" {
    $$$ThrowOnError(##class(CI.Logger).CreateErrorLogFromStream(summary))
    do $System.Process.Terminate(, 1)
  }

  return $$$OK
}

}
