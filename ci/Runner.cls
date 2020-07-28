Include ci

Class CI.Runner
{

ClassMethod Run(configuration As CI.Configuration) As %Status
{
  new $namespace

  set environmentNS = configuration.GetEnv("CI_NAMESPACE")  
  set testManager = configuration.GetEnv("TEST_MANAGER")
  set $namespace = $get(environmentNS, $namespace)

  do ..ResolveConfiguration(configuration, .testSpecs, .flags, .params)
  do ..DescribeConfiguration(testSpecs, flags)

  return ..RunSilently(testManager, testSpecs, flags, .params)
}

ClassMethod ResolveConfiguration(configuration As CI.Configuration, Output testSpecs As %String, Output flags As %String, Output params As %String)
{
  do configuration.GetTestParameters(.params)

  set ^UnitTestRoot = "/opt/ci/app"
  set flags = "/"_configuration.RecurseFlag_"/run/load/nodelete/nodisplay"
  set testSpecs = configuration.TestSuite_":"_configuration.TestCase
}

ClassMethod DescribeConfiguration(testSpecs As %String, flags As %String) [ Private ]
{
  write "Runner: Running test suites from: "_^UnitTestRoot_"."
  write !, "Runner: Flags: "_flags
  write !, "Runner: Spec: "_$select(testSpecs = ":" : "none", 1: testSpecs)
  write !, "Runner: Notice: The test execution summary will be displayed at the end."
}

ClassMethod RunSilently(testManager As %String = "%UnitTest.Manager", testSpecs As %String, flags As %String, ByRef params As %String) As %Status [ Private ]
{
  set io = $io

  open $$$NULL
  use $$$NULL

  if testSpecs = ":" set testSpecs = ""

  set testManagerClass = $select(testManager '= "" : testManager, 1: "%UnitTest.Manager")
  set sc = $classmethod(testManagerClass, "RunTest", testSpecs, flags, .params)

  use io
  close $$$NULL

  return sc
}

ClassMethod OnAfterRun(configuration As CI.Configuration) As %Status
{
  return ..HandleUnitTestFeedback(configuration)
}

ClassMethod HasAnyTestBeenExecuted() As %Boolean [ Private ]
{
  set found = 0
  &sql(SELECT TOP 1 ID INTO :found FROM %UNITTEST_RESULT.TESTASSERT)

  if found = 0 {
    write $$$BOLDYELLOW("No tests suites were found. The runner has been aborted."), !
    return 0
  }

  return 1
}

ClassMethod HandleUnitTestFeedback(configuration As CI.Configuration) As %Status [ Private ]
{
  if '..HasAnyTestBeenExecuted() return $$$OK
  do ..GetAssertionResult(.failure, .success, .error)

  do ..WriteAssertionResult(failure, success, error)
  do ..WriteSummaryFromFailures()
  do ..WriteElapsedTime()

  $$$QuitOnError(..WriteAssertionStatistics(failure, success, error))
  return $$$OK
}

ClassMethod WriteElapsedTime() [ Private ]
{
  set time = 0
  &sql(SELECT TOP 1 DURATION INTO :time FROM %UNITTEST_RESULT.TESTINSTANCE)
  write $$$BOLDDEFAULT("Elapsed time: "_time_" seconds."), !!
}

ClassMethod GetAssertionResult(Output failure As %Integer = 0, Output success As %Integer = 0, Output error As %Integer = 0) [ Private ]
{
  &sql(SELECT COUNT (ID) INTO :success FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 1 AND ACTION <> 'LogMessage')
  &sql(SELECT COUNT (ID) INTO :failure FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 0 AND ACTION <> 'LogMessage')
  &sql(SELECT COUNT (ID) INTO :error FROM %UNITTEST_RESULT.TESTMETHOD WHERE ERRORACTION IS NOT NULL AND ERRORACTION <> '')
}

ClassMethod WriteAssertionResult(failure As %Integer, success As %Integer, error As %Integer) [ Private ]
{
  if error > 0 write $$$BOLDRED("One or more tests have ERRORED."), ! quit
  if failure > 0 write $$$BOLDRED("One or more tests have FAILED."), !  quit
  if success > 0 write $$$BOLDGREEN("All tests have PASSED."), !  quit
}

ClassMethod WriteAssertionStatistics(failure As %Integer = 0, success As %Integer = 0, error As %Integer = 0) As %Status [ Private ]
{
  write $$$BOLDGREEN("✓ "_success_ " assertions have passed."), !
  write $$$BOLDRED("✗ "_failure_" assertions have failed."), !
  if error > 0 write $$$BOLDRED("! "_error_" assertions have errored."), !

  IF failure > 0 || (error > 0) return $$$ERROR($$$GeneralError, "ASSERTION ERROR.")
  return $$$OK
}

ClassMethod  WriteSummaryFromFailures() [ Private ]
{
  write !

  set testResult = ##class(%UnitTest.Result.TestInstance).%OpenId($order(^UnitTest.Result(""), -1))
  for i=1:1:testResult.TestSuites.Count() {
    set testSuite = testResult.TestSuites.GetAt(i)
    if testSuite.Status = 0 {
      write $$$RED("Assertion failure on test suite from "_testSuite.Name), !
      for j=1:1:testSuite.TestCases.Count() {
        set testCase = testSuite.TestCases.GetAt(j)
        if testCase.Status = 0 {
          write $$$RED("  "_"while running "_testCase.Name_"..."), !
          for k=1:1:testCase.TestMethods.Count() {
            set testMethod = testCase.TestMethods.GetAt(k)
            if testMethod.Status = 0 {
              write $$$RED("    "_"and executing the method "_testMethod.Name_"..."), !

              if testMethod.ErrorAction '= "" {
                write $$$BOLDRED("      "_ " aborted the assertion due to an error..."), !
                write $$$BOLDRED("        "_ " with the description: "_testMethod.ErrorDescription), !
                continue
              }

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
