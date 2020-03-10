Class CI.TestRunner.Configuration Extends %RegisteredObject
{

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
  set ..TestSuite = $System.Util.GetEnviron("CI_TESTSUITE")
  set ..TestMethod = $System.Util.GetEnviron("CI_TESTMETHOD")
  set ..RecurseFlag = ..ResolveRecurseFlag()
}

Method ResolveRecurseFlag() As %String
{
  if ..TestMethod = "" return "recursive"
  return "norecursive"
}

}
