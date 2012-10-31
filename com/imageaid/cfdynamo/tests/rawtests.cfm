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
	sTableName = "cfdynamotabletest";
	// sTableName = "temptest01";
	// sTableName = "Forum";
	// sTableName = "ProductCatalog";
	// sTableName = "Reply";
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
	// 	{"id":1000, "Name":"gumdrops", "payload":["alpha","beta","delta","gamma"], "likeChocolate":"true","cows":10}
	// 	, {"id":1001, "Name":"shoemonkey", "payload":["red","orange","yellow","green"], "likeChocolate":"false","cows":0}
	// 	, {"id":1002, "Name":"rimbot", "payload":["peter","paul","mary","puff"], "likeChocolate":"true","cows":42752659}
	// 	, {"id":1003, "Name":"pony", "payload":["peter","paul","mary","puff"], "likeChocolate":"true","cows":559}
	// 	, {"id":1004, "Name":"swiss", "payload":["peter","paul","mary","puff"], "likeChocolate":"false","cows":1337}
	// 	, {"id":1005, "Name":"Carl", "payload":["peter","paul","mary","puff"], "likeChocolate":"false","cows":27}
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
	itemId = 1004;
	writeOutput("Getting item with id #itemId# from the table #sTableName#...<br/>");
	writeDump(ddbc.getItem(tableName=sTableName, hashKey=itemId, attributeNames="id,Name,payload"));
	writeOutput("SUCCESS<br/><br/>");

	// -- DELETE ITEM --
	// if (!isDefined("itemId")) itemId = "crackerbarrel";
	// writeOutput("Deleting item with id #itemId# from table #sTableName#...<br/>");
	// writeDump(ddbc.deleteItem(table_name=sTableName, itemKey=itemId));
	// writeOutput("SUCCESS<br/><br/>");

	// -- QUERY --
	// writeOutput("Querying table #sTableName#...");
	// writeDump(ddbc.queryTable(tableName=sTableName, itemKey="Amazon DynamoDB##DynamoDB Thread 1", comparisonOperator="BETWEEN", comparisonValues=[createDate(2012, 10, 9), now()]));
	// writeOutput("SUCCESS<br/><br/>");

	// -- SCAN --
	// writeOutput("Scanning table #sTableName#...");
	// condition1 =
	// 	{
	// 		"attributeName"="car"
	// 		, "comparisonOperator"="EQ"
	// 		, "comparisonValues"=
	// 		["Mazda"]
	// 	};
	// condition2 =
	// 	{
	// 		"attributeName"="year"
	// 		, "comparisonOperator"="BETWEEN"
	// 		, "comparisonValues"=
	// 		[
	// 			2000
	// 			, 2010
	// 		]
	// 	};
	// aConditions = []; // [condition1,condition2];
	// startKey = {"hashKey"="Amazon DynamoDB##DynamoDB Thread 1", "rangeKey"="2012-10-04T19:03:50.209Z"};
	// startKey = {"hashKey"="100"};
	// writeDump(ddbc.scanTable(tableName=sTableName, conditions=aConditions, limit=20, start=startKey));
	// writeDump(ddbc.scanTable(tableName=sTableName));
	// writeOutput("SUCCESS<br/><br/>");

	// -- DELETE TABLE --
	// writeOutput("Deleting table #sTableName#...<br/>");
	// writeDump(ddbc.deleteTable(sTableName));
	// writeOutput("SUCCESS<br/><br/>");

</cfscript>
<h3>After the script</h3>