<cfcomponent name="util" output="true">

<cffunction name="doCFLog" access="public">
	<cfargument name="textMessage" type="String" required="yes"/>
	<cflog file="R25WSLog" date="yes" thread="yes" type="information" text="#textMessage#" />
</cffunction>


</cfcomponent>
