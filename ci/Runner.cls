Include ci

Class CI.Runner
{

ClassMethod Run(configuration As CI.Configuration) As %Status
{
  new $namespace

  set environmentNS = configuration.GetEnv("CI_NAMESPACE")
  set $namespace = $get(environmentNS, $namespace)

  do configuration.GetTestParameters(.params)

  #define NULL $s($$$isWINDOWS : "//./nul", 1: "/dev/null")

  set ^UnitTestRoot = "/opt/ci/app"
  set flags = "/"_configuration.RecurseFlag_"/run/noload/nodelete/nodisplay"
  set testSpec = configuration.TestSuite_":"_configuration.TestCase

  write "Runner: Running test suites from: "_^UnitTestRoot_"."
  write !, "Runner: Flags: "_flags
  write !, "Runner: Spec: "_$select(testSpec = ":" : "none", 1: testSpec)
  write !, "Runner: Notice: The test execution summary will be displayed at the end."

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

ClassMethod HasAnyTestBeenExecuted() As %Boolean
{
  &sql(SELECT COUNT (ID) INTO :total FROM %UNITTEST_RESULT.TESTASSERT)
  if total = 0 {
    write $$$BOLDYELLOW("No tests suites were found. The runner has been aborted."), !
    return 0
  }

  return 1
}

ClassMethod HandleUnitTestFeedback() As %Status [ Private ]
{
  if '..HasAnyTestBeenExecuted() return $$$OK
  do ..GetAssertionResult(.failure, .success)

  do ..WriteAssertionResult(failure, success)
  do ..WriteSummaryFromFailures()

  $$$QuitOnError(..WriteAssertionStatistics(failure, success))
  return $$$OK
}

ClassMethod GetAssertionResult(Output failure = 0, Output success = 0) [ Private ]
{
  &sql(SELECT COUNT (ID) INTO :success FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 1)
  &sql(SELECT COUNT (ID) INTO :failure FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 0)
}

ClassMethod WriteAssertionResult(failure As %Integer, success As %Integer) [ Private ]
{
  if failure > 0 write $$$BOLDRED("One or more tests have FAILED."), !  quit
  if success > 0 write $$$BOLDGREEN("All tests have PASSED."), !  quit
}

ClassMethod WriteAssertionStatistics(failure As %Integer = 0, success As %Integer = 0) As %Status [ Private ]
{
  write $$$BOLDGREEN("✓ "_success_ " assertions have passed."), !
  write $$$BOLDRED("✗ "_failure_" assertions have failed."), !

  IF failure > 0 return $$$ERROR($$$GeneralError, "ASSERTION ERROR.")
}

ClassMethod  WriteSummaryFromFailures() [ Private ]
{
  write !

  set testResult = ##class(%UnitTest.Result.TestInstance).%OpenId($order(^UnitTest.Result(""), -1))
  for i=1:1:testResult.TestSuites.Count() {
    set testSuite = testResult.TestSuites.GetAt(i)
    if testSuite.Status = 0 {
      write $$$RED("Assertion failure on test suite located at "_testSuite.Name), !
      for j=1:1:testSuite.TestCases.Count() {
        set testCase = testSuite.TestCases.GetAt(j)
        if testCase.Status = 0 {
          write $$$RED("  "_"while running "_testCase.Name_"..."), !
          for k=1:1:testCase.TestMethods.Count() {
            set testMethod = testCase.TestMethods.GetAt(k)
            if testMethod.Status = 0 {
              write $$$RED("    "_"and executing the method "_testMethod.Name_"..."), !
              for l=1:1:testMethod.TestAsserts.Count() {
                set testAssert = testMethod.TestAsserts.GetAt(l)
                if testAssert.Status = 0 {
                  write $$$RED("      "_"failed while asserting the action "_testAssert.Action_" with description: "_testAssert.Description), !
                }
              }
            }
          }
        }
      }
    }
  }
  write !
}

}
