Class CI.TestRunner.Configuration Extends %RegisteredObject
{

Property RecurseFlag As %String;

Property TestSuite As %String;

Property TestCase As %String;

Property Envs As array of %String;

Property TestParameters As %String [ MultiDimensional ];

Method %OnNew(envList As %ArrayOfDataTypes) As %Status
{
  set ..Envs = envList
  do ..ParseTestParameters()
  do ..PrepareTestContext()
  return $$$OK
}

Method PrepareTestContext()
{
  set ..TestSuite = $System.Util.GetEnviron("TEST_SUITE")
  set ..TestCase = $System.Util.GetEnviron("TEST_CASE")
  set ..RecurseFlag = ..ResolveRecurseFlag()
}

Method ParseTestParameters()
{
  set name = ""
  set i%TestParameters = ""

  for i=1:1:..Envs.Count() {
    set name = ..Envs.Next(name)
    if $extract(name, 1, 10) = "TESTPARAM_" {
      set paramName = $extract(name, 11, *)
      set i%TestParameters(paramName) = ..Envs.GetAt(name)
    }
  }
}

Method ResolveRecurseFlag() As %String
{
  if ..TestCase = "" return "recursive"
  return "norecursive"
}

}
