component
	extends="mxunit.framework.TestCase"
	name="DynamoDBClientUnitTest"
	displayName="DynamoDB Client Unit Test"
	hint="I test the various DynamoDB interactions with application code on a unit level.  This test case implement the hard notion of unit testing.  No dependencies, all in-memory, repeatable tests with consistent results."
{



	this["name"] = "DynamoDBClientUnitTest";



	/** MXUnit Test Preparation **/



	public void function beforeTests() {
		writeLog(type="information", file="unittests", text="Starting tests for #this.name# at #now()#.");
	}


	public void function setup() {
		// Choose to use MockBox as our mocking framework
		setMockingFramework('MockBox');
		// And because I don't trust that this will actually take hold, let's explicitly instantiate MockBox
		variables.mockBox = createObject("component","mockbox.system.testing.MockBox").init();
		// Load in our credentials from the XML file
		credentials = xmlParse(expandPath("/aws_credentials.xml"));
		// Instantiate the Component Under Test (CUT) which is the DynamoDB library
		CUT = new com.imageaid.cfdynamo.DynamoDBClient(
			awsKey = credentials.cfdynamo.access_key.xmlText,
			awsSecret = credentials.cfdynamo.secret_key.xmlText
		);
	}


	/** Begin the tests **/


	/**
	 * @hint Make sure that the table name that is set in the request is the same name as the TableDescription that is in the response.
	 **/
	public void function createTableShouldSetTableName() {
		// Let's create a guaranteed unique tablename
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();

		// Extract the Java client from the CUT
		// var awsClient = CUT.getAwsDynamoDBClient();
		// Mock it and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withTableName(stArgs["tableName"])
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Order our CUT to perform the operation
		var awsTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="unittests", text="TEST createTableWithJustUniqueNameShouldCreateTable generated this table: #awsTableDescription.toString()#");
		assertFalse(isDefined("result"));
		// Make sure we found our table in the list of tables
		assertEquals(stArgs["tableName"], awsTableDescription.getTableName(), "The resulting table description instance should be reporing a table name of '#stArgs.tableName#' but is instead reporting '#awsTableDescription.getTableName()#'.");
	}

/*
	public void function createTableWithEmptyNameShouldThrowException()
		mxunit:expectedException="com.amazonaws.AmazonServiceException"
	{
		var result = CUT.createTable(tableName="");
	}
*/

/*
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
*/

/*
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
*/

/*
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
*/


/*
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
*/


/*
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
*/



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