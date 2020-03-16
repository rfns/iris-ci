Class App.Installer
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
    <Log Level="2" Text="CreateCSPApplication: Creating CSP application for ${cspapp}" />
      <Invoke Class="App.Installer" Method="CreateCSPApplication" CheckStatus="1">
        <Arg Value="${cspapp_name}" />
        <Arg Value="${cspapp_authenabled}" />
        <Arg Value="${cspapp_path}" />
        <Arg Value="" />
        <Arg Value="${cspapp_roles}" />
        <Arg Value="${cspapp_recurse}" />
        <Arg Value="${cspapp_servefiles}" />
        <Arg Value="${cspapp_cookiepath}" />
        <Arg Value="${namespace}" />
      </Invoke>
    </IfDef>
    <IfDef Var="restapp">
      <IfDef Var="restapp_dispatchclass">
        <Log Level="2" Text="CreateCSPApplication: Creating REST API for ${restapp}" />
        <Invoke Class="App.Installer" Method="CreateCSPApplication" CheckStatus="1">
          <Arg Value="${restapp_name}" />
          <Arg Value="${restapp_authenabled}" />
          <Arg Value="" />
          <Arg Value="${restapp_dispatchclass}" />
          <Arg Value="${restapp_roles}" />
          <Arg Value="" />
          <Arg Value="${restapp_servefiles}" />
          <Arg Value="${restapp_cookiepath}" />
          <Arg Value="${namespace}" />
      </Invoke>
      </IfDef>
    </IfDef>
  </Namespace>

</Manifest>
}

ClassMethod CreateCSPApplication(cspapp As %String, authEnabled As %String = 32, directory As %String = "", dispatchClass As %String = "", roles As %String ="%All", recurse As %String = 1, serveFiles As %Boolean = 1, cookiePath As %String = "", namespace As %String = "") As %Status
{
  new $namespace
  set $namespace = "%SYS"

  set params("AuthEnabled") = authMethods
  set params("AutoCompile") = 1
  set params("CSPZENEnabled") = 1
  set params("CookiePath") = cookiePath
  set params("DeepSeeEnabled") = 1
  set params("Description") = ""
  set params("DispatchClass") = dispatchClass
  set params("Enabled") = 1
  set params("InbndWebServicesEnabled") = 1
  set params("IsNameSpaceDefault") = $case(dispatchClass, "": 1, : 0)
  set params("LockCSPName") = 1
  set params("MatchRoles") = roles
  set params("NameSpace") = namespace
  set params("Path") = directory
  set params("Recurse") = recurse
  set params("iKnowEnabled") = 1
  set params("UseCookies") = 2

  return ##class(Security.Applications).Create(cspapp, .params)
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
