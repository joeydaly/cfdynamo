<cfscript>
	try{
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = credentials.cfdynamo.access_key.xmlText, 
			aws_secret = credentials.cfdynamo.secret_key.xmlText
		);	
		if(structKeyExists(url,"tbl")){
			cfdynamo.delete_table(trim(url.tbl));
		}
		my_tables = cfdynamo.list_tables(limit=1);
	}
	catch(Any e){
		my_tables = e;
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - List Tables</title>
	</head>
	<body>
		<cfoutput>
		<h1>List Tables - Results</h1>
		<cfif structKeyExists(url,"tbl")>
			<p>Note: It takes a few moments for AWS to delete a DynamoDB table. I would expect, with this iteration of CFDynamo, that the table you just deleted shows up in the listing ... reload the page (without the tbl value in the URL) in a minute or two to see if it's gone.</p>
			<p><a href="#cgi.script_name#">reload page</a></p>
		</cfif>		
			<ul>
			<cfloop array="#my_tables#" index="table_name">
				<li><a href="#cgi.script_name#?tbl=#table_name#">#table_name#</a></li>
			</cfloop>
			</ul>
		</cfoutput>
	</body>
</html>