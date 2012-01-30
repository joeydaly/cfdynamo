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
		my_tables = cfdynamo.list_tables();
	}
	catch(Any e){
		my_tables = e;
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - Delete Table</title>
	</head>
	<body>
		<cfoutput>
		<h1>Existing Tables</h1>
		<cfif structKeyExists(url,"tbl")>
			<p>Note: It takes a few moments for AWS to delete a DynamoDB table. I would expect, with this iteration of CFDynamo, that the table you just deleted shows up in the listing ... reload the page (without the tbl value in the URL) in a minute or two to see if it's gone.</p>
			<p><a href="#cgi.script_name#">reload page</a></p>
		</cfif>		
		<p>Click on a table name to delete it. Note, this is a testing page so there is no warning, confirmation or other crap. Do this at your own risk :)!</p>
			<ul>
			<cfloop array="#my_tables#" index="table_name">
				<li><a href="#cgi.script_name#?tbl=#table_name#">#table_name#</a></li>
			</cfloop>
			</ul>
		</cfoutput>
	</body>
</html>