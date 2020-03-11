Class CI.TestRunner.Runner
{

ClassMethod Run(configuration As CI.TestRunner.Configuration) As %Status
{
  new $namespace

  set environmentNS = configuration.Envs.GetAt("CI_NAMESPACE")
  set $namespace = $get(environmentNS, $namespace)

  #define NULL $s($$$isWINDOWS : "//./nul", 1: "/dev/null")

  set ^UnitTestRoot = "/opt/ci/root"
  set flags = "/"_configuration.RecurseFlag_"/run/noload/nodelete/nodisplay"
  set testSpec = configuration.TestSuite_":"_configuration.TestCase

  write !, "Running test suites from: "_^UnitTestRoot_"."
  write !, "Flags: "_flags
  write !, "Spec: "_testSpec

  write !!, "The test execution summary will be displayed below. Please standby ..."

  set io = $io

  open $$$NULL
  use $$$NULL

  set sc = ##class(%UnitTest.Manager).RunTest(testSpec, flags)

  use io
  close $$$NULL

  return sc
}

}
