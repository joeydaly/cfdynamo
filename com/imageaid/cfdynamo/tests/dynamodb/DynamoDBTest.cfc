component extends="mxunit.framework.TestCase" name="DynamoDBTest" displayName="DynamoDBTest" hint="I test the various DynamoDB interactions"{
	


	public void function beforeTests() {
		// Start tracking all tables that are created so we can delete them when we're done.
		variables.tablesCreated = [];
	}


	public void function setup() {
		credentials = xmlParse(expandPath("/aws_credentials.xml"));
		CUT = new com.imageaid.cfdynamo.DynamoDBClient(
			awsKey = credentials.cfdynamo.access_key.xmlText, 
			awsSecret = credentials.cfdynamo.secret_key.xmlText
		);
	}
	
	public void function awsDynamoDBNorthVirginiaShoudlBeAlive() {
		var expected = "Service is operating normally";
		var xmlStatus = xmlParse("http://status.aws.amazon.com/rss/dynamodb-us-east-1.rss");
		var actual = xmlStatus.XmlRoot.XmlChildren[1].XmlChildren[10].XmlChildren[1].XmlText;
		assertTrue(findNoCase(expected, actual), "The expected string, '#expected#', should appear in the actual string, '#actual#'.");
	}


	public void function createTableWithJustUniqueNameShouldCreateTable() {
		// Let's create a guaranteed unique tablename
		var sTableName = "cfdynamo-unit-tests-" & createUUID();
		var awsTableDescription = CUT.createTable(tableName=sTableName);
		assertFalse(isDefined("result"));
		// Make sure we found our table in the list of tables
		assertEquals(sTableName, awsTableDescription.getTableName(), "The resulting table description instance should be reporing a table name of '#sTableName#' but is instead reporting '#awsTableDescription.getTableName()#'.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, sTableName);
	}
	
	
	public void function createTableWithEmptyNameShouldThrowException()
		mxunit:expectedException="com.amazonaws.AmazonServiceException"
	{
		var result = CUT.createTable(tableName="");
	}
	
	
	public void function createTableShouldAssignReadWriteThroughput() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["readCapacity"] = 7;
		stArgs["writeCapacity"] = 3;
		// Create our table with custom read/write provisioning that is NOT the default values
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		// Assert that our returned values from the serice report true
		assertEquals(awsTableDescription.getProvisionedThroughput().getReadCapacityUnits(), stArgs["readCapacity"]);
		assertEquals(awsTableDescription.getProvisionedThroughput().getWriteCapacityUnits(), stArgs["writeCapacity"]);
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}
	
	
	public void function afterTests() {
		// Delete all tables that were made during the integration tests
		for (var table in variables.tablesCreated) {
			// Check to see that the status is active - we can't delete a table that's being created, and it takes
			// up to a minute for the creation to complete. Note that this will slow down the completion fo the test.
			do {
				sleep(2000);
				// Log this for debug purposes. I hate when good loops go bad and you don't know why.
				writeLog(type="information", file="unittests", text="Sleeping for two seconds waiting for #CUT.getTableInformation(table).status# to be ACTIVE.");
			} while (CUT.getTableInformation(table).status != "ACTIVE");
			// If we made it here, we're out of the loop and the table is active, which is to say it's ready to be deleted
			CUT.deleteTable(table);
		}
	}
/*
	public void function test_list_tables(){
		assertFalse(true,"Dang, list tables should be false.");
	} 
	
	public void function test_create_table(){
		assertFalse(true,"Dang, create tavle also be false.");
	}
	
	public void function test_delete_table(){
		assertFalse(true,"Dang, delete table should be false.");
	}
	
	public void function test_put_item(){
		assertFalse(true,"Dang, put item should be false.");
	}
	
	public void function test_get_item(){
		assertFalse(true,"Dang, get item should be false.");
	}
	
	public void function test_update_table(){
		assertFalse(true,"Dang, update table should be false.");
	}
*/


	
}