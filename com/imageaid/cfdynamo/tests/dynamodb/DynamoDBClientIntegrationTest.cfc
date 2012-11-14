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
		writeLog(type="information", file="integrationtests", text="Starting integration tests for #this.name# at #now()#.");
	}


	public void function setup() {
		// Load in our credentials from the XML file
		credentials = xmlParse(expandPath("/aws_credentials.xml"));
		// Instantiate the Component Under Test (CUT) which is the DynamoDB library
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
		var sTableName = "cfdynamo-integration-tests-" & createUUID();
		var stTableDescription = CUT.createTable(tableName=sTableName);
		writeLog(type="information", file="integrationtests", text="TEST createTableWithJustUniqueNameShouldCreateTable generated this table: #stTableDescription.toString()#");
		assertFalse(isDefined("result"));
		// Make sure we found our table in the list of tables
		assertEquals(sTableName, stTableDescription.tableName, "The resulting table description instance should be reporing a table name of '#sTableName#' but is instead reporting '#stTableDescription.tableName#'.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	/**
	 * @mxunit:expectedException "com.amazonaws.AmazonServiceException"
	 **/
	public void function createTableWithEmptyNameShouldThrowException()
	{
		var result = CUT.createTable(tableName="");
	}


	public void function createTableShouldAssignReadWriteThroughput() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integration-tests-" & createUUID();
		stArgs["readCapacity"] = 7;
		stArgs["writeCapacity"] = 3;
		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="integrationtests", text="TEST createTableShouldAssignReadWriteThroughput generated this table: #stTableDescription.toString()#");
		// Assert that our returned values from the serice report true
		assertEquals(stArgs["readCapacity"], stTableDescription.readCapacity, "The specified read capacity of #stArgs['readCapacity']# doesn't match the read capacity returned from the service's table description.");
		assertEquals(stArgs["writeCapacity"], stTableDescription.writeCapacity, "The specified write capacity of #stArgs['writeCapacity']# doesn't match the write capacity returned from the service's table description.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription["tableName"]);
	}


	public void function tableShouldBeCreatedWithSpecifiedStringHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integration-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "String";
		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="integrationtests", text="TEST tableShouldBeCreatedWithSpecifiedStringHashKey generated this table: #stTableDescription.toString()#");
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], stTableDescription.keys.hashKey.name, "The returned name of the hash key is not what was assigned during table creation.");
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], stTableDescription.keys.hashKey.type, "The returned type of the kash key is not what was assigned during table creation.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericHashKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integration-tests-" & createUUID();
		stArgs["hashKeyName"] = "myTestHashKeyName";
		stArgs["hashKeyType"] = "Numeric";
		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="integrationtests", text="TEST tableShouldBeCreatedWithSpecifiedNumericHashKey generated this table: #stTableDescription.toString()#");
		// Take a look at the name of the hashKey, assert that it is what we specified above
		assertEquals(stArgs["hashKeyName"], stTableDescription.keys.hashKey.name, "The returned hashKey name was not set to the value it was assigned.");
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["hashKeyType"], stTableDescription.keys.hashKey.type, "The returned hashKey type was not set to the type assigned.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	public void function tableShouldBeCreatedWithSpecifiedStringRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integration-tests-" & createUUID();
		stArgs["rangeKeyName"] = "myTestHashKeyName";
		stArgs["rangeKeyType"] = "String";
		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="integrationtests", text="TEST tableShouldBeCreatedWithSpecifiedStringRangeKey generated this table: #stTableDescription.toString()#");
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], stTableDescription.keys.rangeKey.name, "The returned name of the range key is not what was assigned during table creation.");
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], stTableDescription.keys.rangeKey.type, "The returned type of the range key is not what was assigned during table creation.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	public void function tableShouldBeCreatedWithSpecifiedNumericRangeKey() {
		// Setup an argument collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integration-tests-" & createUUID();
		stArgs["rangeKeyName"] = "myTestHashKeyName";
		stArgs["rangeKeyType"] = "Numeric";
		// Create our table with custom read/write provisioning that is NOT the default values
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		writeLog(type="information", file="integrationtests", text="TEST tableShouldBeCreatedWithSpecifiedNumericRangeKey generated this table: #stTableDescription.toString()#");
		// Take a look at the name of the rangeKey, assert that it is what we specified above
		assertEquals(stArgs["rangeKeyName"], stTableDescription.keys.rangeKey.name, "The returned range key name is not what it was assigned.");
		// Now assert that it is of the same data type we specified
		assertEquals(stArgs["rangeKeyType"], stTableDescription.keys.rangeKey.type, "The returned range key type is not what was assigned.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	public void function updateTableShouldOverwriteSpecifiedTableAttributes() {
		// Setup arg collection
		var stArgs = {};
		stArgs["tableName"] = "cfdynamo-integrationtest-updateTable-#hour(now())#-#minute(now())#-#getTickCount()#";
		stArgs["readCapacity"] = 8;
		stArgs["writeCapacity"] = 6;
		// First we need to create the table.  Afterwards we will update it and make assertions
		var stTableDescription = CUT.createTable(argumentcollection=stArgs);
		// Now engage a while loop because we need to wait until the status of the table is ACTIVE to perform the update
		do {
			sleep(1000);
		} while (CUT.getTableInformation(stTableDescription.tableName).status != "ACTIVE");
		// If we made it here past the while loop, we're ready to update the table. Modify our read and write capacity
		stArgs["readCapacity"] = 6;
		stArgs["writeCapacity"] = 4;
		var blnSuccess = CUT.updateTable(argumentcollection=stArgs);
		// Make sure we received a true
		assertTrue(blnSuccess, "The response from the updateTable method was not true, and should have been.");
		// Also make sure that the table now has those new properties.  We will need another while loop because the table
		// will have entered an UPDATING status as it re-provisions the capacity.
		do {
			sleep(330);
		} while (CUT.getTableInformation(stTableDescription.tableName).status != "ACTIVE");
		// Ok, get the table information so we can make assertions
		var stUpdatedTableDescription = CUT.getTableInformation(stTableDescription.tableName);
		assertEquals(stArgs["readCapacity"], stUpdatedTableDescription.readCapacity, "The read capacity reported from the service is not the new updated value.");
		assertEquals(stArgs["writeCapacity"], stUpdatedTableDescription.writeCapacity, "The write capacity reported from the service is not the new updated value.");
		// Add the table name to our list of created tables so we can delete it at the end of the tests
		arrayAppend(variables.tablesCreated, stTableDescription.tableName);
	}


	public void function listTablesShouldReturnArrayOfTableNamesWhenThereAreTables() {
		fail("Test not implemented.");
	}


	public void function deleteTableShouldChangeStatusOfActiveTableToDeleting() {
		fail("Test not implemented.");
	}


	public void function putItemShouldAddItemIntoSpecifiedTable() {
		fail("Test not implemented.");
	}


	public void function getItemShouldReturnRequestedItem() {
		fail("Test not implemented.");
	}


	public void function deleteItemShouldRemoveSpecifiedItemFromTable() {
		fail("Test not implemented.");
	}


	public void function batchPutItemsShouldInsertAllSentItemsIntoTable() {
		fail("Test not implemented.");
	}


	public void function batchDeleteItemsShouldRemoveAllSpecifiedItemsFromTable() {
		fail("Test not implemented.");
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
			writeLog(type="information", file="integrationtests", text="Tests have created #arrayLen(variables.tablesCreated)# - starting while loop to delete them in another thread.");

			for (var table in variables.tablesCreated) {
				// Check to see that the status is active - we can't delete a table that's being created, and it takes
				// up to a minute for the creation to complete. Note that this will slow down the completion fo the test.
				// Do all this in async threads so we don't have to wait too long for test results.  That's annoying.
				thread action="run" name="delete-#table#" table="#table#" checkinterval="4000" CUT="#CUT#" {
					do {
						sleep(checkinterval);
						// Log this for debug purposes. I hate when good loops go bad and you don't know why.
						writeLog(type="information", file="integrationtests", text="Thread for deleting #table# is sleeping for #checkinterval#ms waiting for an ACTIVE status. Current status: #CUT.getTableInformation(table).status#");
					} while (CUT.getTableInformation(table).status != "ACTIVE");
					// If we made it here, we're out of the loop and the table is active, which is to say it's ready to be deleted
					writeLog(type="information", file="integrationtests", text="Thread for deleting #table# sees its status is ACTIVE now. Proceeding with the deletion.");
					CUT.deleteTable(table);
				}
			}
		}
		writeLog(type="information", file="integrationtests", text="Closing integration tests for #this.name# at #now()#.");
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