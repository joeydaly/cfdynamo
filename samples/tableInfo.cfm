<cfsetting enablecfoutputonly="true">
<cfscript>
	stInfo = application.aws.cfdynamo.getTableInformation(url.table);
</cfscript>
<cfoutput>#serializeJSON(stInfo)#</cfoutput>