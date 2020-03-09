Class CI.TestRunner.Configuration Extends %RegisteredObject
{
Property Root As %String;

Property RecurseFlag As %String;

Property TestSuite As %String;

Property TestMethod As %String;

Method %OnNew() As %Status
{
  do ..PrepareTestContext()
  return $$$OK
}

Method PrepareTestContext()
{
  set ..Root = $System.Util.GetEnviron("CI_TESTROOT")
  set ..TestSuite = $System.Util.GetEnviron("CI_TESTSUITE")
  set ..TestMethod = $System.Util.GetEnviron("CI_TESTMETHOD")
  set ..RecurseFlag = ..ResolveRecurseFlag()
}

Method ResolveRecurseFlag() As %String
{
  if ..TestMethod '= "" return "recursive"
  return ""
}

}
