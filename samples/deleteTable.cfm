<cftry>
	<cfset result = application.aws.cfdynamo.deleteTable(url.table) />
	<cfoutput>
		<h3>Results</h3>
		<p>
			Table: #result.tableName#<br />
			Table status: #result.status#<br />
		</p>
	</cfoutput>
	<cfcatch type="any">
		<cfif (cfcatch.errorCode eq "ResourceNotFoundException")>
			<h3>That table does not exist.</h3>
		<cfelse>
			<cfrethrow />
		</cfif>
	</cfcatch>
</cftry>