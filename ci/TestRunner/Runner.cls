Class CI.TestRunner.Runner [ Abstract ]
{

ClassMethod Run(configuration As CI.TestRunner.Configuration) As %Status
{
  set ^UnitTestRoot = "/opt/ci/root"

  return ##class(%UnitTest.Manager).RunTest(
    configuration.TestSuite_":"_configuration.TestMethod,
    "/"_configuration.RecursiveFlag_"/run/noload/nodelete/nodisplay"
  )
}

}
