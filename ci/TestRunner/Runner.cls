Class CI.TestRunner.Runner [ Abstract ]
{

ClassMethod Run(configuration As CI.TestRunner.Configuration) As %Status
{
  new $namespace
  set $namespace = $get($System.Util.GetEnviron("CI_NS"), $namespace)

  #define NULL $s($$$isWINDOWS : "//./nul", 1: "/dev/null")

  set ^UnitTestRoot = "/opt/ci/root"_$System.Util.GetEnviron("CI_TESTROOT")
  set flags = "/"_configuration.RecurseFlag_"/run/noload/nodelete/nodisplay"
  set testSpec = configuration.TestSuite_":"_configuration.TestMethod

  write !, "Running test suites from: "_^UnitTestRoot_"."
  write !, "Flags: "_flags
  write !, "Spec: "_testSpec, !!

  write "The test execution summary will be displayed below. Please standby ...", !

  set io = $io

  open $$$NULL
  use $$$NULL

  set sc = ##class(%UnitTest.Manager).RunTest(testSpec, flags)

  use io
  close $$$NULL

  return sc
}

}
