Class CI.TestRunner.Configuration Extends %RegisteredObject
{

Property RecurseFlag As %String;

Property TestSuite As %String;

Property TestCase As %String;

Property Envs As array of %String;

Method %OnNew(envList As %ArrayOfDataTypes) As %Status
{
  set ..Envs = envList
  do ..PrepareTestContext()
  return $$$OK
}

Method PrepareTestContext()
{
  set ..TestSuite = $System.Util.GetEnviron("CI_TESTSUITE")
  set ..TestCase = $System.Util.GetEnviron("CI_TESTCASE")
  set ..RecurseFlag = ..ResolveRecurseFlag()
}

Method ResolveRecurseFlag() As %String
{
  if ..TestCase = "" return "recursive"
  return "norecursive"
}

}
