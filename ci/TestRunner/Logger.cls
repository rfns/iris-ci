Include %occStatus

Class CI.TestRunner.Logger
{

ClassMethod CreateErrorLogFromStatus(status) As %Status
{
  set fs = ##class(%Stream.FileCharacter).%New()
  do fs.LinkToFile("/var/log/ci/errors.log")
  set content = $piece($System.Status.GetErrorText(status), ":", 2, *)
  do fs.Write(content)
  return fs.%Save()
}

ClassMethod CreateErrorLogFromStream(stream As %Stream.Object) As %Status
{
  set fs = ##class(%Stream.FileCharacter).%New()
  do fs.LinkToFile("/var/log/ci/errors.log")
  do fs.CopyFrom(stream)
  return fs.%Save()
}

ClassMethod RegisterAssertionStatistics() As %Status
{
  set success = 0
  set failure = 0

  &sql(SELECT COUNT (ID) INTO :success FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 1)
  &sql(SELECT COUNT (ID) INTO :failure FROM %UNITTEST_RESULT.TESTASSERT WHERE STATUS = 0)

  set fs = ##class(%Stream.FileCharacter).%New()
  do fs.LinkToFile("/var/log/ci/testsuccess.log")
  set fs.TranslateTable = "UTF8"
  do fs.Write("✓ "_success_ " assertions have passed.")
  do fs.%Save()
  set fs = ""

  set fs = ##class(%Stream.FileCharacter).%New()
  set fs.TranslateTable = "UTF8"
  do fs.LinkToFile("/var/log/ci/testfailure.log")
  do fs.Write("✗ "_failure_ " assertions have failed.")
  return fs.%Save()
}

ClassMethod  CreateSummaryFromFailures(Output msg As %Stream.FileCharacter = "") As %Status
{
  set msg = ##class(%Stream.FileCharacter).%New()
  set testResult = ##class(%UnitTest.Result.TestInstance).%OpenId($order(^UnitTest.Result(""), -1))
  for i=1:1:testResult.TestSuites.Count() {
    set testSuite = testResult.TestSuites.GetAt(i)
    if testSuite.Status = 0 {
      do msg.WriteLine("Assertion failure on test suite located at "_testSuite.Name)
      for j=1:1:testSuite.TestCases.Count() {
        set testCase = testSuite.TestCases.GetAt(j)
        if testCase.Status = 0 {
          do msg.WriteLine("  "_"while running "_testCase.Name_"...")
          for k=1:1:testCase.TestMethods.Count() {
            set testMethod = testCase.TestMethods.GetAt(k)
            if testMethod.Status = 0 {
              do msg.WriteLine("    "_"and executing the method "_testMethod.Name_"...")
              for l=1:1:testMethod.TestAsserts.Count() {
                set testAssert = testMethod.TestAsserts.GetAt(l)
                if testAssert.Status = 0 {
                  do msg.WriteLine("      "_"failed while asserting the action "_testAssert.Action_" with description: "_testAssert.Description)
                }
              }
            }
          }
        }
      }
    }
  }
  return $$$OK
}
}
