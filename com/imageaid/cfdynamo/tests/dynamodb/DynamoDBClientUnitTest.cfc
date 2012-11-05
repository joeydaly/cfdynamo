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

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
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
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Make sure we found our table in the list of tables
		assertEquals(stArgs["tableName"], stTableInfo["tableName"], "The resulting table description instance should be reporing a table name of '#stArgs.tableName#' but is instead reporting '#stTableInfo.tableName#'.");
	}


	public void function createTableWithEmptyNameShouldThrowException()
		mxunit:expectedException="com.amazonaws.AmazonServiceException"
	{
		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$(method="createTable", throwException=true, throwType="com.amazonaws.AmazonServiceException", throwMessage="The paramater 'tableName' must be at least 3 characters long and at most 255 characters long", throwDetail="This is a mocked exception.");
		CUT.setAwsDynamoDBClient(oAWSMock);
		// Perform the testing operation
		var result = CUT.createTable(tableName="");
	}


	public void function createTableShouldAssignReadWriteThroughput() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["readCapacity"] = 7;
		stArgs["writeCapacity"] = 3;

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withTableName(stArgs["tableName"])
				.withProvisionedThroughput(createObject("java", "com.amazonaws.services.dynamodb.model.ProvisionedThroughputDescription")
					.init()
					.withReadCapacityUnits(stArgs["readCapacity"])
					.withWriteCapacityUnits(stArgs["writeCapacity"])
				)
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Assert that our returned values from the serice report true
		assertEquals(stArgs["readCapacity"], stTableInfo["readCapacity"], "The specified read capacity of #stArgs['readCapacity']# doesn't match the read capacity returned from the service's table description.");
		assertEquals(stArgs["writeCapacity"], stTableInfo["writeCapacity"], "The specified write capacity of #stArgs['writeCapacity']# doesn't match the write capacity returned from the service's table description.");
	}



	public void function tableShouldBeCreatedWithSpecifiedStringHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "String";

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withKeySchema(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchema")
					.init()
					.withHashKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["hashKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["hashKeyType"]))
					)
				)
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Create our table with a specifically named string hash key
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], stTableInfo["keys"]["hashKey"]["name"]);
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], stTableInfo["keys"]["hashKey"]["type"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "Numeric";

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withKeySchema(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchema")
					.init()
					.withHashKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["hashKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["hashKeyType"]))
					)
				)
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Create our table with a specifically named numeric hash key
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], stTableInfo["keys"]["hashKey"]["name"]);
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], stTableInfo["keys"]["hashKey"]["type"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedStringRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "String";
		stArgs["rangeKeyName"] = "myTestRangeKeyName";
		stArgs["rangeKeyType"] = "String";

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withKeySchema(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchema")
					.init()
					.withHashKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["hashKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["hashKeyType"]))
					)
					.withRangeKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["rangeKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["rangeKeyType"]))
					)
				)
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Create our table with custom named string rangeKey
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], stTableInfo["keys"]["rangeKey"]["name"]);
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], stTableInfo["keys"]["rangeKey"]["type"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-unit-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "String";
		stArgs["rangeKeyName"] = "myTestRangeKeyName";
		stArgs["rangeKeyType"] = "Numeric";

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("createTable", createObject("java", "com.amazonaws.services.dynamodb.model.CreateTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withKeySchema(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchema")
					.init()
					.withHashKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["hashKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["hashKeyType"]))
					)
					.withRangeKeyElement(createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
						.init()
						.withAttributeName(stArgs["rangeKeyName"])
						.withAttributeType(CFMLTypeToAWSAttributeValueType(stArgs["rangeKeyType"]))
					)
				)
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Create our table with custom named string rangeKey
		var stTableInfo = CUT.createTable(argumentcollection=stArgs);
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], stTableInfo["keys"]["rangeKey"]["name"]);
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], stTableInfo["keys"]["rangeKey"]["type"]);
	}


	/** Tests for listTables **/


	public Void function listTablesShouldReturnArrayOfStrings() {
		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual
		// AWS services, and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		var aInputTableNames = ["TestTable01","TestTable02","TestTable03","TestTable04"];
		oAWSMock.$("listTables", createObject("java", "com.amazonaws.services.dynamodb.model.ListTablesResult")
			.init()
			.withTableNames(aInputTableNames)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Get our table listing
		var aResultingTableNames = CUT.listTables();
		// Make sure it's an array
		assertTrue(isArray(aResultingTableNames), "The value returned from listTables is not an array!");
		// It needs to be the same array that we fed into the method
		assertEquals(aInputTableNames, aResultingTableNames, "The array of table names that came out doesn't look like the array that went in.");
	}


	/** Tests for deleteTable **/


	public Void function deleteTableShouldReportBackNameOfDeletedTable() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "someDeletedTableName";

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("deleteTable", createObject("java", "com.amazonaws.services.dynamodb.model.DeleteTableResult")
			.init()
			.withTableDescription(createObject("java", "com.amazonaws.services.dynamodb.model.TableDescription")
				.init()
				.withTableName(stArgs["tableName"])
			)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Delete the table
		var stDeletedTableInfo = CUT.deleteTable(argumentcollection=stArgs);
		// Make sure the name of the table that went in matches the name that came back
		assertEquals(stArgs["tableName"], stDeletedTableInfo["tableName"], "The name of the deleted table that came out doesn't match the name that went in!");
	}


	/** Tests for putItem **/


	public Void function putItemWillYieldOldRecordWhenReplacingExistingItem() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "someTableThatContainsExistingRecord";
		stArgs["item"] = {"id":1000, "title":"Replacement for a record that already exists", "Flavor":"vanilla"};

		// Setup the complex Java object that will represent a simulated return from the AWS put operation
		var returnedItem = createObject("java", "java.util.HashMap").init();
		returnedItem.put("id", createObject("java", "com.amazonaws.services.dynamodb.model.AttributeValue").init().withN("1000"));
		returnedItem.put("title", createObject("java", "com.amazonaws.services.dynamodb.model.AttributeValue").init().withS("Replacement for a record that already exists"));
		returnedItem.put("Flavor", createObject("java", "com.amazonaws.services.dynamodb.model.AttributeValue").init().withS("chocolate"));

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("putItem", createObject("java", "com.amazonaws.services.dynamodb.model.PutItemResult")
			.init()
			.withAttributes(returnedItem)
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Perform the putItem operation. We are expecting a CFML native struct that contains the old item. In this test
		// scenario, we have updated the record from a flavor of chocolate to that of vanilla.  The old value, chocolate,
		// is what would be returned by the service according to the AWS SDK documentation.
		var stOldItem = CUT.putItem(argumentcollection=stArgs);
		// Assert that the returning structure has some keys in it, which proves it was a replacement, not a new record creation
		assertTrue(listLen(structKeyList(stOldItem)) > 0, "There are no keys in the struct that returned, which should not happen when updating an item.");
	}


	public Void function putItemWillYieldEmptyStructWhenAddingNewItem() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "someTableThatContainsExistingRecord";
		stArgs["item"] = {"id":1001, "title":"New record that didn't exist before", "Flavor":"strawberry"};

		// Mock the Java client itself and redefine the createTable function to skip any outreach to actual AWS services,
		// and basically setup the very table information we asked it to set in the first place.
		var oAWSMock = variables.mockBox.createStub();
		oAWSMock.$("putItem", createObject("java", "com.amazonaws.services.dynamodb.model.PutItemResult")
			.init()
		);
		CUT.setAwsDynamoDBClient(oAWSMock);

		// Perform the putItem operation. We are expecting a CFML native struct that contains the old item. In this test
		// scenario, we have updated the record from a flavor of chocolate to that of vanilla.  The old value, chocolate,
		// is what would be returned by the service according to the AWS SDK documentation.
		var stOldItem = CUT.putItem(argumentcollection=stArgs);
		// Assert that the returning structure has no keys in it, which proves it was an addition as opposed to a replacement of an old item
		assertTrue(listLen(structKeyList(stOldItem)) == 0, "There are no keys in the struct that returned, which should not happen when updating an item.");
	}



	/** Private helper methods, these are not tests **/



	/**
	 * @author Adam Bellas
	 * @displayname Convert CFML type to AWS AttributeValue Type
	 * @hint In order to properly set AttributeValue data types on the AWS SDK class instances we need to convert map CFML types to their AWS SDK equivalents.
	 **/
	private String function CFMLTypeToAWSAttributeValueType(
		required String val hint="The CFML style data type string, which will be String or Numeric")
	{
		switch (arguments.val) {
			case "String":
				return "S";
				break;
			case "Numeric":
				return "N";
				break;
			default:
				throw(type="Application.Validation", message="Unknown type, cannot convert.", detail="Only String and Numeric can be converted to AWS enumerated attribute value types at this time.");
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