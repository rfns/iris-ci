Include %occStatus

Class CI.Orchestrator
{

ClassMethod Orchestrate() As %Status
{
  try {
    write !, "Orchestrator: Compiling runtime classes ...", !
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/App/Installer.cls", "/compile"))
    $$$ThrowOnError($System.OBJ.Load("/opt/ci/Runner.cls", "/compile"))

    $$$ThrowOnError(..GetEnvironmentVars(.vars, .envList))

    write !
    $$$ThrowOnError(##class(App.Installer).setup(.vars))
    write !

    set configuration = ##class(CI.Configuration).%New(envList)

    $$$ThrowOnError(##class(CI.Runner).Run(configuration))
    $$$ThrowOnError(##class(CI.Runner).OnAfterRun(configuration))
  } catch ex {
    set status = ex.AsStatus()
    do ##class(CI.Logger).CreateErrorLogFromStatus(status)
    do $System.Process.Terminate(, 1)
  }

  return $$$OK
}

ClassMethod GetEnvironmentVars(Output vars As %String = "", Output envs As %ArrayOfDataTypes = "") As %Status
{
  set envs = ##class(DotEnv.Parser).FromPath("/opt/ci")
  set name = ""

  if $isobject(envs) {
    for i=1:1:envs.Count() {
      set name = envs.Next(name)
      set value = envs.GetAt(name)
      if $extract(name, 1, 3) = "CI_" {
        set vars($$$lcase($replace(name, "CI_", ""))) = value
      }
    }
  }

  return $$$OK
}

}
