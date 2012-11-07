<!---
auth.cfc

ColdFusion Component for authenticating against ActiveDirectory (via LDAP)
--->
<cfcomponent name="auth" output="false">
<cfset fixture = false />
<!---
 Simple GET web service to return the current information in the session as JSON
--->
<cffunction name="auth" access="remote" returntype="Struct" returnformat="json" output="false">
	<cflock scope="Session" timeout="2" type="Exclusive">
	<cfscript>
		//Iif(IsDefined("Session.MM_Username"),"Session.MM_Username",DE(""))/>
		if (isDefined("Session.ADResult")) {
			if (Session.authenticated AND IsDefined("Session.ADResult")) {
				auth_dt = ParseDateTime(Session.adresult.auth_dt);
				initDiff = dateDiff("n", auth_dt, now());
				if (initDiff GT 1) {
					Session.username = "";
					lookup();
				}
			} else {
				lookup();
			}
		} else {
			lookup();
		}
	</cfscript>
	</cflock>
	<cfreturn Session />
</cffunction>

<!---
  LDAP lookup
--->
<cffunction name="lookup" access="package" output="true">
<cfset result = StructNew() />
<cfset today = "#DateFormat(now(), 'long')# #TimeFormat(now(), 'long')#" />

<cfif fixture>
	<cfset Session.username = "abc123" />
	<cfscript>
		result.name = "John Doe";
		result.fname = "John";
		result.lname = "Doe";
		result.dept = "Department";
		result.banner = "01234567";
		result.username = "abc123";
		result.email = "john.doe@does.edu";
		result.auth_dt = today;
		result.state = "SUCCESS";
	</cfscript>
	<cflock scope="Session" timeout="5" type="Exclusive">
		<cfset Session.authenticated = true />
		<cfset Session.ADResult = result />
	</cflock>
<cfelse>

<cftry>
<cflock scope="Session" timeout="2" type="ReadOnly">
	<cfset username = Session.username />
</cflock>
	<cfif Session.username EQ "">
		<cfthrow detail="invalid username" />
	</cfif>
	<cfldap action="Query" name="ADResult"
		attributes="cn,givenName,sn,department,employeeID,sAMAccountName,mail"
		start="#Application.base_dn#"
		filter="(&(objectclass=user)(sAMAccountName=#username#))"
		server="#Application.ad_server#"
		scope = "subtree"
		username="#Application.LDAPBindUser#@utsarr.net" password="#Application.LDAPBindPassword#" />
	<cfscript>
		result.name = ADResult.cn;
		result.fname = ADResult.givenName;
		result.lname = ADResult.sn;
		result.dept = ADResult.department;
		result.banner = ADResult.employeeID;
		result.username = ADResult.sAMAccountName;
		result.email = ADResult.mail;
		result.auth_dt = today;
		result.state = "SUCCESS";
	</cfscript>
	<cflock scope="Session" timeout="2" type="Exclusive">
		<cfset Session.authenticated = true />
		<cfset Session.ADResult = result />
	</cflock>
<cfcatch type="ANY">
	<cfset logme = Application.util.doCFLog("#cfcatch.Message#")/>
	<cflock scope="Session" timeout="2" type="Exclusive">
		<cfset result.state = "FAIL" />
		<cfset Session.authenticated = false />
		<cfset ADResult.state = cfcatch.Message />
		<cfset Session.ADResult = result />
	</cflock>
</cfcatch>
</cftry>

</cfif>
</cffunction>

</cfcomponent>

