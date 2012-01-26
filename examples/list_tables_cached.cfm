<cfscript>
	try{
		my_tables = application.aws.cfdynamo.list_tables(limit=1);
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
	</body>
</html>