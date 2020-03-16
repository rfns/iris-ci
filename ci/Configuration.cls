Class CI.Configuration Extends %RegisteredObject
{

Property RecurseFlag As %String [ ReadOnly ];

Property TestSuite As %String [ ReadOnly ];

Property TestCase As %String [ ReadOnly ];

Property Envs As array of %String [ Private ];

Property TestParameters As %String [ MultiDimensional, Private ];

Method %OnNew(envList As %ArrayOfDataTypes) As %Status
{
  set ..Envs = envList
  do ..ParseTestParameters()
  do ..PrepareTestContext()
  return $$$OK
}

Method GetEnv(name As %String) As %Status
{
  return ..Envs.GetAt(name)
}

Method PrepareTestContext() [ Private ]
{
  set i%TestSuite = $System.Util.GetEnviron("TEST_SUITE")
  set i%TestCase = $System.Util.GetEnviron("TEST_CASE")
  set i%RecurseFlag = ..ResolveRecurseFlag()
}

Method ParseTestParameters() [ Private ]
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

Method ResolveRecurseFlag() As %String [ Private ]
{
  if ..TestCase = "" return "recursive"
  return "norecursive"
}

Method GetTestParameters(Output testParams = "")
{
  merge testParams = i%TestParameters
}

}
