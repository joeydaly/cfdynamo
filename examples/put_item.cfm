<cfscript>
	credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
	cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
		aws_key = credentials.cfdynamo.access_key.xmlText, 
		aws_secret = credentials.cfdynamo.secret_key.xmlText
	);		
	put_item = {};
	put_item.kronumteamid = createUUID();
	put_item.kronumteamidrange = 0;
	put_item.team_name = "Mo-Mos";
	try{
		put_item = cfdynamo.put_item(table_name="KronumTeamsTest", item=put_item);
	}
	catch(Any e){
		put_item = e;
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - Put Item to Table</title>
	</head>
	<body>
		<h1>Put Item</h1>
		<cfdump var="#put_item#">
	</body>
</html>
