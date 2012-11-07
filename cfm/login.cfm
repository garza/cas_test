
<!--- // Login.cfm
 
// ColdFusion MX 6.1 code that uses CAS 2.0
 
// Christian Stuck
// stuckc@rider.edu
// Westminster Choir College
// Princeton, New Jersey 

// John David Garza
// john.garza@utsa.edu
// University of Texas at San Antonio
// San Antonio, Texas 78249
// 05/31/2012 - Modifications made for CF8, general usability
	- pulled CAS variables out into Application.cfc
	- Cleaned up some casurl code for readability
	- Defined ServiceApp, ServiceCASPath, ServiceErrorPath for easier configurability
--->
<cflock scope="Session" type="ReadOnly" timeout="30" throwontimeout="no">
 <cfset MM_Username=Iif(IsDefined("Session.MM_Username"),"Session.MM_Username",DE(""))/>
 <cfset MM_UserAuthorization=Iif(IsDefined("Session.MM_UserAuthorization"),"Session.MM_UserAuthorization",DE(""))/>
</cflock>
<!--- See if already logged on --->
<cfif MM_Username EQ "">
	<!--- Check for ticket returned by CAS redirect --->
	<cfset ticket=Iif(IsDefined("URL.ticket"),"URL.ticket",DE("")) />
	<cfif ticket EQ "">
		<!--- No session, no ticket, Redirect to CAS Logon page --->
		<cfset casurl = "#Application.CAS_Server#&login?service=#Application.ServiceApp##Application.ServiceCASPath#">
		<cflocation url="#casurl#" addtoken="no"/>
	<cfelse>
		<!--- Back from CAS, validate ticket and get userid --->
		<cfset casurl = "#Application.CAS_Server#serviceValidate?ticket=#URL.ticket#&service=#Application.ServiceApp##Application.ServiceCASPath#" />
		<cfhttp url="#casurl#" method="GET"/>
		<!---
		<cfhttp url="#casurl#" method="POST" />
		--->
		<cfset objXML = xmlParse(cfhttp.filecontent) />
		<cfscript>
			Application.util.doCFLog("#casurl#");
			Application.util.doCFLog("#CFHTTP.filecontent#");
		</cfscript>
		<cfset SearchResults = XmlSearch(objXML, "cas:serviceResponse/cas:authenticationSuccess/cas:user") />
		<cfif NOT ArrayIsEmpty(SearchResults)>
			<cfset NetId = #SearchResults[1].XmlText#/>
		<cfelse>
			<cflocation url="#Application.ServiceErrorPath#" addtoken="no" />
		</cfif>
	</cfif>
</cfif>
 
<cflock scope="Session" timeout="2" type="Exclusive">
	<cfset Session.username= NetId />
</cflock>

<cflocation url="#Application.ServiceSuccessPath#" addtoken="no" />