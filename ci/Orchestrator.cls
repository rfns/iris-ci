Include ci

Class CI.Orchestrator
{

ClassMethod Orchestrate() As %Status
{
  try {
    $$$ThrowOnError(..CompileRuntime())
    $$$ThrowOnError(..GetEnvironmentVars(.vars, .envList))
    $$$ThrowOnError(..RunInstallerSetup(.vars))

    set configuration = ..GetRunnerConfiguration(envList)

    $$$ThrowOnError(..StartRunner(configuration))
    $$$ThrowOnError(..TerminateRunner(configuration))
    do ..DisplayTerminationNotice()
  } catch ex {
    return ..HandleException(ex)
  }

  return $$$OK
}

ClassMethod HandleException(ex As %Exception.StatusException) As %Status [ Private ]
{
  set status = ex.AsStatus()
  write !, $$$RED("Orchestrator: ***WARNING*** Aborting due to errors and exit with non-zero code."), !!
  set content = $zstrip($piece($System.Status.GetErrorText(status), ":", 2, *), "<>W")
  write $$$RED(content), !!
  return $System.Process.Terminate(, 1)
}

ClassMethod DisplayTerminationNotice() [ Private ]
{
  write !, "Orchestrator: Notice: All tasks have been completed. The instance will now be terminated gracefully.", !!
}

ClassMethod GetRunnerConfiguration(envList As %ListOfDataTypes) As CI.Configuration [ Private ]
{
  write !, "Orchestrator: Configuring the runner."
  set configuration = ##class(CI.Configuration).%New(envList)
  return configuration
}

ClassMethod StartRunner(configuration As CI.Configuration) As %Status [ Private ]
{
  write !, "Orchestrator: Starting the runner.", !!
  $$$QuitOnError(##class(CI.Runner).Run(configuration))
  write !!
  return $$$OK
}

ClassMethod TerminateRunner(configuration As CI.Configuration) As %Status [ Private ]
{
  $$$QuitOnError(##class(CI.Runner).OnAfterRun(configuration))
  write !!, "Orchestrator: Runner has terminated without errors."
  return $$$OK
}

ClassMethod CompileRuntime() As %Status [ Private ]
{
  write !, "Orchestrator: Compiling runtime classes."
  $$$QuitOnError($System.OBJ.Load("/opt/ci/App/Installer.cls", "/compile/nodisplay"))
  $$$QuitOnError($System.OBJ.Load("/opt/ci/Runner.cls", "/compile/nodisplay"))
  return $$$OK
}

ClassMethod RunInstallerSetup(ByRef vars  As %String = "") As %Status [ Private ]
{
    write !, "Orchestrator: Running the installer setup.", !!
    $$$QuitOnError(##class(App.Installer).setup(.vars))
    return $$$OK
}

ClassMethod GetEnvironmentVars(Output vars As %String = "", Output envs As %ArrayOfDataTypes = "") As %Status [ Private ]
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
