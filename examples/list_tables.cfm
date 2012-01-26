<cfscript>
	try{
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = credentials.cfdynamo.access_key.xmlText, 
			aws_secret = credentials.cfdynamo.secret_key.xmlText
		);	
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
		<h1>List Tables - Results</h1>
		<cfdump var="#my_tables#">
		<cfdump var="#my_tables.getTableNames()#">		
	</body>
</html>