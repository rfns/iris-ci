Class CI.App.Installer
{

XData setup
{
<Manifest>
  <Default Name="ns" Value='#{$System.Util.GetEnviron("CI_NS")}'/>
  <Default Name="app" Value='#{$System.Util.GetEnviron("CI_CSPAPP")}' />
  <Default Name="pwd" Value='#{$System.Util.GetEnviron("PWD")}' />
  <Default Name="dispatchclass" Value='#{$System.Util.GetEnviron("CI_RESTDISPATCHCLASS")}' />
  <Default Name="restapp" Value='#{$System.Util.GetEnviron("CI_RESTAPP")}' />

  <Namespace Name="${ns}" Code="${ns}" Data="${ns}" Create="yes" Ensemble="no">
    <Configuration>
      <Database Name="${ns}" Dir="/opt/ci/data" Create="yes" Resource="%DB_${ns}" />
      <Import File="/opt/ci/root" Flags="/compile/nodisplay" Recurse="1" IgnoreErrors="1" />
    </Configuration>
    <If Condition="$data(app)">
      <CSPApplication Url="${app}" Directory="${cspdir}${app}"  ServeFiles="1" Recurse="1" MatchRoles="%All" AuthenticationMethods="32"/>
    </If>
    <If Condition="$data(dispatchclass)">
      <CSPApplication Url="${restapp}" DispatchClass="${dispatchclass}"  ServeFiles="1" Recurse="1" MatchRoles="%All" AuthenticationMethods="32"/>
    </If>
  </Namespace>

</Manifest>
}

ClassMethod setup(
	ByRef pVars,
	pLogLevel As %Integer = 3,
	pInstaller As %Installer.Installer,
	pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}
