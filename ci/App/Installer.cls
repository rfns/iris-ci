Class CI.App.Installer
{

XData setup
{
<Manifest>
  <Default Name="namespace" Value="USER"/>
  <Namespace Name="${namespace}" Code="${namespace}" Data="${namespace}" Create="yes" Ensemble="no">
    <Configuration>
      <Database Name="${namespace}" Dir="/opt/ci/data" Create="yes" Resource="%DB_${namespace}" />
      <Import File="/opt/ci/app" Flags="/compile/nodisplay" Recurse="1" IgnoreErrors="1" />
    </Configuration>
    <IfDef Var="cspapp">
      <CSPApplication Url="${cspapp}" Directory="${cspdir}${cspapp}"  ServeFiles="1" Recurse="1" MatchRoles="%All" AuthenticationMethods="32"/>
    </IfDef>
    <IfDef Var="restapp">
      <IfDef Var="restdispatchclass">
        <CSPApplication Url="${restapp}" DispatchClass="${restdispatchclass}" Directory="/opt/_dummycsp" ServeFiles="1" Recurse="1" MatchRoles="%All" AuthenticationMethods="32"/>
      </IfDef>
    </IfDef>
  </Namespace>

</Manifest>
}

ClassMethod setup(
	ByRef pVars,
	pLogLevel As %Integer = 2,
	pInstaller As %Installer.Installer,
	pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}
