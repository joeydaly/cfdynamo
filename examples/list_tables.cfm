<cfscript>
	try{
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = credentials.cfdynamo.access_key.xmlText, 
			aws_secret = credentials.cfdynamo.secret_key.xmlText
		);	
		my_tables = cfdynamo.list_tables();
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
		<h1>List Tables - Results</h1>
		<cfoutput>
			<ul>
			<cfloop array="#my_tables#" index="table_name">
				<li>#table_name#</li>
			</cfloop>
			</ul>
		</cfoutput>
	</body>
</html>