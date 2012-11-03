component
	extends="mxunit.framework.TestCase"
	name="DynamoDBTest"
	displayName="DynamoDBTest"
	hint="I test the various DynamoDB interactions"
{



	this["name"] = "DynamoDBTest";



	/** MXUnit Test Preparation **/


	public void function beforeTests() {
		// Start tracking all tables that are created so we can delete them when we're done.
		variables.tablesCreated = [];
		writeLog(type="information", file="unittests", text="Starting unit tests for #this.name# at #now()#.");
	}


	public void function setup() {
		credentials = xmlParse(expandPath("/aws_credentials.xml"));
		CUT = new com.imageaid.cfdynamo.DynamoDBClient(
			awsKey = credentials.cfdynamo.access_key.xmlText,
			awsSecret = credentials.cfdynamo.secret_key.xmlText
		);
	}


	/** Begin the tests **/


	public void function awsDynamoDBNorthVirginiaShoudlBeAlive() {
		var expected = "Service is operating normally";
		var xmlStatus = xmlParse("http://status.aws.amazon.com/rss/dynamodb-us-east-1.rss");
		var actual = xmlStatus.XmlRoot.XmlChildren[1].XmlChildren[10].XmlChildren[1].XmlText;
		assertTrue(findNoCase(expected, actual), "The expected string, '#expected#', should appear in the actual string, '#actual#'.");
	}


	/**
	 * @hint This is a simple test, as simple as it gets, for creating a table and checking that it's there.
	 **/
	public void function createTableWithJustUniqueNameShouldCreateTable() {
		// Let's create a guaranteed unique tablename
		var sTableName = "cfdynamo-unit-tests-" & createUUID();
		var awsTableDescription = CUT.createTable(tableName=sTableName);
		writeLog(type="information", file="unittests", text="TEST createTableWithJustUniqueNameShouldCreateTable generated this table: #awsTableDescription.toString()#");
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
		writeLog(type="information", file="unittests", text="TEST createTableShouldAssignReadWriteThroughput generated this table: #awsTableDescription.toString()#");
		// Assert that our returned values from the serice report true
		assertEquals(awsTableDescription.getProvisionedThroughput().getReadCapacityUnits(), stArgs["readCapacity"], "The specified read capacity of #stArgs['readCapacity']# doesn't match the read capacity returned from the service's table description.");
		assertEquals(awsTableDescription.getProvisionedThroughput().getWriteCapacityUnits(), stArgs["writeCapacity"], "The specified write capacity of #stArgs['writeCapacity']# doesn't match the write capacity returned from the service's table description.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedStringHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "String";
		// Create our table with custom read/write provisioning that is NOT the default values
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="unittests", text="TEST tableShouldBeCreatedWithSpecifiedStringHashKey generated this table: #awsTableDescription.toString()#");
		// Pull the KeySchema out of the TableDescription
		var awsKeySchema = awsTableDescription.getKeySchema();
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], awsKeySchema.getHashKeyElement().getAttributeName());
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], awsAttributeValueTypeToCFMLType(awsKeySchema.getHashKeyElement().getAttributeType()));
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "Numeric";
		// Create our table with custom read/write provisioning that is NOT the default values
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="unittests", text="TEST tableShouldBeCreatedWithSpecifiedNumericHashKey generated this table: #awsTableDescription.toString()#");
		// Pull the KeySchema out of the TableDescription
		var awsKeySchema = awsTableDescription.getKeySchema();
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], awsKeySchema.getHashKeyElement().getAttributeName());
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], awsAttributeValueTypeToCFMLType(awsKeySchema.getHashKeyElement().getAttributeType()));
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedStringRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["rangeKeyName"] = "myTestHashKeyName";
		stArgs["rangeKeyType"] = "String";
		// Create our table with custom read/write provisioning that is NOT the default values
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="unittests", text="TEST tableShouldBeCreatedWithSpecifiedStringRangeKey generated this table: #awsTableDescription.toString()#");
		// Pull the KeySchema out of the TableDescription
		var awsKeySchema = awsTableDescription.getKeySchema();
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], awsKeySchema.getRangeKeyElement().getAttributeName());
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], awsAttributeValueTypeToCFMLType(awsKeySchema.getRangeKeyElement().getAttributeType()));
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["rangeKeyName"] = "myTestHashKeyName";
		stArgs["rangeKeyType"] = "Numeric";
		// Create our table with custom read/write provisioning that is NOT the default values
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="unittests", text="TEST tableShouldBeCreatedWithSpecifiedNumericRangeKey generated this table: #awsTableDescription.toString()#");
		// Pull the KeySchema out of the TableDescription
		var awsKeySchema = awsTableDescription.getKeySchema();
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], awsKeySchema.getRangeKeyElement().getAttributeName());
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], awsAttributeValueTypeToCFMLType(awsKeySchema.getRangeKeyElement().getAttributeType()));
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stArgs["tableName"]);
	}



	/** Private helper methods, these are not tests **/



	/**
	 * @author Adam Bellas
	 * @displayname Convert AWS AttributeValue Type to CFML Type
	 * @hint In order to ensure the proper data types were set on fields in the DynamoDB tables I needed some way to compare it to CF types.  This conversion is used to do that.
	 **/
	private String function awsAttributeValueTypeToCFMLType(
		required String val hint="The AWS style attribute type string, which will be S, N, or B")
	{
		switch (arguments.val) {
			case "S":
				return "String";
				break;
			case "N":
				return "Numeric";
				break;
			case "B":
				throw(type="Application.Validation", message="Cannot convert AWS type #arguments.val# to CFML type.", detail="There is no currently supported conversion in this library from AWS binary to CFML data type.");
				break;
		}
	}


	/** End of tests, begin cleanup method **/


	public void function afterTests() {
		if (arrayLen(variables.tablesCreated)) {
			// Delete all tables that were made during the integration tests
			writeLog(type="information", file="unittests", text="Tests have created #arrayLen(variables.tablesCreated)# - starting while loop to delete them.");
			for (var table in variables.tablesCreated) {
				// Check to see that the status is active - we can't delete a table that's being created, and it takes
				// up to a minute for the creation to complete. Note that this will slow down the completion fo the test.
				do {
					var nSleepLength = 3500;
					sleep(nSleepLength);
					// Log this for debug purposes. I hate when good loops go bad and you don't know why.
					writeLog(type="information", file="unittests", text="Sleeping for #nSleepLength#ms waiting for table #table#'s status, which is now #CUT.getTableInformation(table).status#, to be ACTIVE.");
				} while (CUT.getTableInformation(table).status != "ACTIVE");
				// If we made it here, we're out of the loop and the table is active, which is to say it's ready to be deleted
				CUT.deleteTable(table);
			}
		}
		writeLog(type="information", file="unittests", text="Closing unit tests for #this.name# at #now()#.");
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