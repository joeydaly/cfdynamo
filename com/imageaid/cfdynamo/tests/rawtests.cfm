<h3>Before the script</h3>
<cfscript>

	// We already have the connector instantiated in the application scope.  Alias it to
	// the local page scope so we can re-instantiate it in case we feel like it here.
	credentials = xmlParse(expandPath("/aws_credentials.xml"));
	application.aws.cfdynamo = new com.imageaid.cfdynamo.DynamoDBClient(
		awsKey = credentials.cfdynamo.access_key.xmlText,
		awsSecret = credentials.cfdynamo.secret_key.xmlText
	);
	ddbc = application.aws.cfdynamo;


	// -- CHOOSE A TABLE BY UNCOMMENTING ONE --
	// sTableName = "cfdynamotabletest";
	// sTableName = "temptest01";
	// sTableName = "Forum";
	sTableName = "ProductCatalog";
	// sTableName = "Reply";

	// -- CREATE TABLE --
	// writeOutput("creating table #sTableName#...<br/>");
	// stArgs = {};
	// stArgs["tableName"] = sTableName;
	// stArgs["hashKeyName"] = "identifier";
	// stArgs["hashKeyType"] = "string";
 	// stArgs["rangeKeyName"] = "make";
	// stArgs["rangeKeyType"] = "string";
	// stArgs["readCapacity"] = 10;
	// stArgs["writeCapacity"] = 2;
	// ddbc.createTable(argumentCollection=stArgs);
	// writeOutput("SUCCESS<br/><br/>");

	// -- UPDATE TABLE --
	// nRC = 8;
	// nWC = 2;
	// writeOutput("Updating table, setting the throughput to #nRC#/#nWC#.<br/>");
	// ddbc.updateTable(tableName=sTableName, readCapacity=nRC, writeCapacity=nWC);
	// writeOutput("SUCCESS<br/><br/>");

	// -- LIST TABLES --
	// writeOutput("Listing tables...<br/>");
	// writeDump(ddbc.listTables());
	// writeOutput("SUCCESS<br/><br/>");

	// -- TABLE INFO --
	// writeOutput("Getting details for table #sTableName#...<br/>");
	// writeDump(ddbc.getTableInformation(sTableName));
	// writeOutput("SUCCESS<br/><br/>");

	// -- PUT ITEM --
	// writeOutput("Here's a sample object we will create for insertion.<br/>");
	// oSample = {"Name":"crackerbarrel", "payload":["foo","bar","knee","toes"], "likeChocolate":"false","cows":93};
	// writeDump(var=oSample, label="Sample Data");
	// writeOutput("Putting our sample record into the table #sTableName#...<br/>");
	// writeDump(ddbc.putItem(tableName=sTableName, item=oSample));
	// writeOutput("SUCCESS<br/><br/>");

	// -- BATCH PUT ITEM --
	// aSampleItems = [
	// 	{"Id":300, "Name":"gumdrops", "payload":["alpha","beta","delta","gamma"], "likeChocolate":"true","cows":10}
	// 	, {"Id":3001, "Title":"shoemonkey", "Brand":"Pepsi Co.", "likeChocolate":"false","cows":0}
	// 	, {"Id":302, "Title":"rimbot", "Brand":"Mattel", "likeChocolate":"true","cows":42752659}
	// 	, {"Id":303, "Title":"pony", "Brand":"Johnson & Johnson", "likeChocolate":"true","cows":559}
	// 	, {"Id":304, "Title":"swiss", "Brand":"Nestles", "likeChocolate":"false","cows":1337}
	// 	, {"Id":305, "Title":"Carl", "Brand":"Bughatti", "likeChocolate":"false","cows":27}
	// ];
	// writeOutput("Here are #arrayLen(aSampleItems)# sample objects we will create for batch insertion.<br/>");
	// writeDump(var=aSampleItems, label="Sample Data for insertion", expand=false);
	// writeOutput("Batch putting our sample data into the table #sTableName#...<br/>");
	// writeDump(ddbc.batchPutItems(tableName=sTableName, items=aSampleItems));
	// writeOutput("SUCCESS<br/><br/>");

	// // --- BATCH DELETE ITEM ---
	// writeOutput("This works with the batch put above.  Be sure to let that run first to generate the data we will now batch delete.<br/>");
	// aSampleItems = [
	// 	{"hashKey":1000}
	// 	, {"hashKey":1001}
	// 	, {"hashKey":1002}
	// ];
	// writeDump(var=aSampleItems, label="Sample Data for deletion", expand=false);
	// writeOutput("Batch deleting our sample data from the table #sTableName#...<br/>");
	// writeDump(ddbc.batchDeleteItems(tableName=sTableName, items=aSampleItems));
	// writeOutput("SUCCESS<br/><br/>");

	// -- GET ITEM --
	// itemId = "Adam Test 01";
	// stArgs = {};
	// stArgs["tableName"] = sTableName;
	// stArgs["hashKey"] = itemId;
	// stArgs["rangeKey"] = createDateTime(2012, 12, 22, 0, 0, 0);
	// stArgs["attributeNames"] = "Id,ReplyDateTime,Message";
	// writeOutput("Getting item with id #itemId# from the table #sTableName#...<br/>");
	// writeDump(ddbc.getItem(argumentcollection=stArgs));
	// writeOutput("SUCCESS<br/><br/>");

	// -- DELETE ITEM --
	// itemId = "Adam Test 01";
	// stArgs = {};
	// stArgs["tableName"] = sTableName;
	// stArgs["hashKey"] = itemId;
	// stArgs["rangeKey"] = "2012-12-22T00:00:00.000Z";
	// writeOutput("Deleting item with id #itemId# from table #sTableName#...<br/>");
	// writeDump(ddbc.deleteItem(argumentcollection=stArgs));
	// writeOutput("SUCCESS<br/><br/>");

	// -- QUERY --
	// stArgs = {};
	// stArgs["tableName"] = sTableName;
	// stArgs["hashKey"] = "Amazon DynamoDB##DynamoDB Thread 1";
	// stArgs["comparisonOperator"] = "BETWEEN";
	// stArgs["comparisonValues"] = [createDate(2012, 10, 9), now()];
	// stArgs["startKey"] = {"hashKey":"Amazon DynamoDB##DynamoDB Thread 1", "rangeKey":createDateTime(2012, 10, 11, 19, 6, 21, 564)};
	// writeOutput("Querying table #sTableName#...");
	// writeDump(ddbc.queryTable(argumentcollection=stArgs));
	// writeOutput("SUCCESS<br/><br/>");

	// -- SCAN --
	// writeOutput("Scanning table #sTableName#...");
	// condition1 =
	// 	{
	// 		"attributeName"="Title"
	// 		, "comparisonOperator"="BEGINS_WITH"
	// 		, "comparisonValues"=
	// 		["s"]
	// 	};
	// condition2 =
	// 	{
	// 		"attributeName"="Price"
	// 		, "comparisonOperator"="GT"
	// 		, "comparisonValues"=
	// 		[400]
	// 	};
	// aConditions = [condition1,condition2];
	// stArgs = {};
	// stArgs["tableName"] = sTableName;
	// stArgs["conditions"] = aConditions;
	// stArgs["limit"] = 4;
	// stArgs["startKey"] = {"hashKey"="100"};
	// writeDump(ddbc.scanTable(argumentcollection=stArgs));
	// writeOutput("SUCCESS<br/><br/>");

	// -- DELETE TABLE --
	// writeOutput("Deleting table #sTableName#...<br/>");
	// writeDump(ddbc.deleteTable(sTableName));
	// writeOutput("SUCCESS<br/><br/>");

</cfscript>
<h3>After the script</h3>