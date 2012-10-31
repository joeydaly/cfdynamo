/**
* @accessors true
* @displayname CFML Amazon AWS DynamoDB Client
* @hint I handle interactions with an Amazon SDK DynamoDB instance.  To use me, you must have the Amazon SDK jar file in the classpath.
*/
component

	accessors="true"
	output="false"

{

	
	property name="awsKey" type="string" hint="The AWS Key";
	property name="awsSecret" type="string" hint="The AWS Secret";
	property name="awsCredentials" type="object";
	property name="awsDynamoDBClient" type="object";
	
	variables.awsKey = "";
	variables.awsSecret = "";


	/**
	* @displayname Initialize
	* @hint Returns an initialized instance of this class.  It is intended to be instantiated and used most optimally as a singleton.
	*/
	public DynamoDBClient function init(
			required string awsKey
			, required string awsSecret
			, boolean useHTTPS=false
			, string awsZone="us-east-1")
	{
		variables.awsKey = trim(arguments.awsKey);
		variables.awsSecret = trim(arguments.awsSecret);
		variables.awsCredentials = createObject("java","com.amazonaws.auth.BasicAWSCredentials").init(variables.awsKey, variables.awsSecret);
		variables.awsDynamoDBClient = createObject("java","com.amazonaws.services.dynamodb.AmazonDynamoDBClient").init(awsCredentials);
		if (arguments.useHTTPS)
		{
			variables.awsDynamoDBClient.setEndpoint("http://dynamodb.#trim(arguments.awsZone)#.amazonaws.com");
		}
		return this;
	}
	

	/**
	* @displayname Create Table
	* @hint Creates a new DynamoDB table.
	*/
	public Void function createTable(
		required String tableName hint="Name of the table to be created"
		, required String hashKeyName="id" hint="Name of the field in the table that will function as the primary key"
		, required String hashKeyType="numeric"
		, String rangeKeyName
		, String rangeKeyType="string"
		, Numeric readCapacity=5
		, Numeric writeCapacity=5)
	{
		// Create a validated and sanitized copy of the arguments scope to be used in this function
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["hashKeyName"] = trim(arguments.hashKeyName);
		pargs["hashKeyType"] = trim(arguments.hashKeyType);
		pargs["readCapacity"] = arguments.readCapacity;
		pargs["writeCapacity"] = arguments.writeCapacity;
		// These next two might not even be defined
		if (structKeyExists(arguments, "rangeKeyName")) pargs["rangeKeyName"] = trim(arguments.rangeKeyName);
		if (structKeyExists(arguments, "rangeKeyType")) pargs["rangeKeyType"] = trim(arguments.rangeKeyType);

		// Start setting up the creation parameters
		var readCapacityCasted = JavaCast("long",pargs.readCapacity);
		var writeCapacityCasted = JavaCast("long",pargs.writeCapacity);
		var awsHashKeyType = ( lcase(pargs.hashKeyType) == 'numeric' ? "N" : "S" );
		var awsHashKey = createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
			.init()
			.withAttributeName(pargs.hashKeyName)
			.withAttributeType(awsHashKeyType);

		// Create the KeySchema, which feeds into our CreateTableRequest
		var awsKeySchema = createObject("java","com.amazonaws.services.dynamodb.model.KeySchema")
			.init()
			.withHashKeyElement(awsHashKey);

		// If a range key was provided in the parameters, define one
		if (structKeyExists(pargs, "rangeKeyName") && structKeyExists(pargs, "rangeKeyType"))
		{
			// Determine the type
			var awsRangeKeyType = ( lcase(pargs.rangeKeyType) == 'numeric' ? "N" : "S" );
			// Create our range representational key schema element
			var awsRangeKey = createObject("java", "com.amazonaws.services.dynamodb.model.KeySchemaElement")
				.init()
				.withAttributeName(pargs.rangeKeyName)
				.withAttributeType(awsRangeKeyType);
			// Assign it to the KeySchema we made already
			awsKeySchema.setRangeKeyElement(awsRangeKey);
		}

		// Define the provisioned throughput based on provided parameters
        var awsProvisionedThroughput = createObject("java","com.amazonaws.services.dynamodb.model.ProvisionedThroughput")
			.init()
			.withReadCapacityUnits(readCapacityCasted)
			.withWriteCapacityUnits(writeCapacityCasted);

		// Finally, make the create table request, using all the things we've built up so far        
        var awsTableRequest = createObject("java","com.amazonaws.services.dynamodb.model.CreateTableRequest")
        	.init()
        	.withTableName(pargs.tableName)
        	.withKeySchema(awsKeySchema)
        	.withProvisionedThroughput(awsProvisionedThroughput);
        
        // Perform the request in a try purely to give us a way to log it.  We love log files!
        try {
        	variables.awsDynamoDBClient.createTable(awsTableRequest);
        }
        catch(Any e) {
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb");
        	rethrow;
        }
		return;
	}


	/**
	* @displayname Get Table Information
	* @hint Retrieves detailed information about the specified table.
	*/
    public Struct function getTableInformation(
    	required String tableName hint="Name of the table to get information about.")
    {
    	// Private sanitized copy of the arguments scope
    	var pargs = {"tableName":trim(arguments.tableName)};

        var awsDescribeTableRequest = createObject("java", "com.amazonaws.services.dynamodb.model.DescribeTableRequest")
        	.init()
        	.withTableName(pargs["tableName"]);
        var result = awsDynamoDBClient.describeTable(awsDescribeTableRequest);
        var awsTableDescription = result.getTable();

        // The result is messy for ColdFusion so let's map it to a basic struct with the properties of the table as keys
		var stTableInfo = {};
		stTableInfo["name"] = awsTableDescription.getTableName();
		stTableInfo["status"] = awsTableDescription.getTableStatus();
		stTableInfo["read capacity"] = awsTableDescription.getProvisionedThroughput().getReadCapacityUnits();
		stTableInfo["write capacity"] = awsTableDescription.getProvisionedThroughput().getWriteCapacityUnits();
		// Return the struct
		return stTableInfo;
    }	


	/**
	* @displayname Update Table
	* @hint Modifies the specified table. The only changes one can make with the AWS SDK is the read and write capacity. This method handles modifying those values.
	*/
	public boolean function updateTable(
		required string tableName hint="Name of the table to be updated"
		, required numeric readCapacity hint="Number of capacity units per second throughput that is required of the table for read operations"
		, required numeric writeCapacity hint="Number of capacity units per second throughput that is required of the table for write operations")
	{
		// Create a validated and sanitized copy of the arguments scope to be used in this function
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["readCapacity"] = arguments.readCapacity;
		pargs["writeCapacity"] = arguments.writeCapacity;

		// Transform our capacities into Java longs
		var readCapacityCasted = JavaCast("long", pargs.readCapacity);
		var writeCapacityCasted = JavaCast("long", pargs.writeCapacity);

		var awsProvisionedThroughput = createObject("java","com.amazonaws.services.dynamodb.model.ProvisionedThroughput")
			.init()
            .withReadCapacityUnits(readCapacityCasted)
            .withWriteCapacityUnits(writeCapacityCasted);
		var update_table_request = createObject("java", "com.amazonaws.services.dynamodb.model.UpdateTableRequest")
			.init()
			.withTableName(pargs.tableName)
			.withProvisionedThroughput(awsProvisionedThroughput);

		// Make the call to AWS        
        try{
        	var result = variables.awsDynamoDBClient.updateTable(update_table_request);
        }
        catch(Any e){
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb");
        	rethrow;
        }

        // Always return true since we throw an exception if something went wrong
		return true;
	}
	

	/**
	* @displayname Delete Table
	* @hint Deletes the specified table. Use with care, there is no confirmation for this operation.  All data will be lost!
	*/
	public Void function deleteTable(
		required String tableName hint="Name of the table that is to be deleted")
	{
		// Create a validated and sanitized copy of the arguments scope to be used in this function
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		// Build the delete table request that will be passed into the client
		var awsDeleteTableRequest = createObject("java","com.amazonaws.services.dynamodb.model.DeleteTableRequest")
			.init()
			.withTableName(pargs.tableName);
		// Attempt the deletion
        try {
        	var result = variables.awsDynamoDBClient.deleteTable(awsDeleteTableRequest);
        }
        catch(Any e) {
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb");
        	rethrow;
        }
        // Don't return anything. This could be enhanced to return the details of the table that was deleted, if necessary.
        return;
	}
	

	/**
	* @displayname List Tables
	* @hint Lists all the tables present in the DynamoDB account.  If no limit is provided, all tables are listed. You may optionally provide the name of a table to start the result set from in order to support paginated results.
	*/
	public Array function listTables(
		string startTable hint="Optional. If provided, the result set's page will begin with this table."
		, numeric limit=20 hint="Optional, defaults to 20. Specifies the maximum number of items in the result set, for pagination.")
	{
		// Create a validated and sanitized copy of the arguments scope to be used in this function
		var pargs = {};
		if (structKeyExists(arguments, "startTable")) pargs["startTable"] = trim(arguments.startTable);
		if (structKeyExists(arguments, "limit")) pargs["limit"] = arguments.limit;
		// Setup the list request
		var awsTableRequest = createObject("java","com.amazonaws.services.dynamodb.model.ListTablesRequest")
			.init()
			.withLimit(pargs.limit);
		// Conditionally add in the start table name, if it was provided
		if (structKeyExists(pargs, "startTable"))
		{
			awsTableRequest.setExclusiveStartTableName(arguments.startTable);
		}
		// Make the call to AWS, returning the result
		return variables.awsDynamoDBClient.listTables(awsTableRequest).getTableNames();
	}
	

	/**
	* @displayname Put Item
	* @hint Adds a record to a specified DynamoDB table.  The entirety of the record is specified by a single simple struct.  Note that DynamoDB only supports structs two levels deep, i.e. you can have a struct of strings as the value for one of you top level struct keys, however you cannot then embed deeper structs within that.
	*/
	public Any function putItem(
		required string tableName hint="Name of the table into which the provided data will be inserted as a record."
		, required struct item hint="Struct containing the data that is to become the new record in the table.")
	{
		// Create a validated and sanitized copy of the arguments scope to be used in this function
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["item"] = arguments.item;

		var awsPutItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.PutItemRequest")
			.init()
			.withTableName(pargs.tableName)
			.withItem(struct_to_dynamo_map(pargs.item));
		var result = variables.awsDynamoDBClient.putItem(awsPutItemRequest);
		return result;
	}


	/**
	* @author Adam Bellas
	* @displayname Batch Put Items
	* @hint Utilizes the batch put capabilities of the AWS Java SDK.  The items are provided in the form of an array of structs.  The structs are the items to be batch inserted into the table specified.
	*/
	public Void function batchPutItems(
		required String tableName hint="Name of the table into which the provided data will be inserted as a record."
		, required Array items hint="Collection (array) of Structs that are each containing the data that is to become new records in the specified table.")
	{
		// Make a sanitized version of arguments scoped values we will use
		var pargs = {
			"tableName" = trim(arguments.tableName),
			"items" = arguments.items
		};
		// Build the request items that ultimately feeds into the batch write item request
		var requestItems = {};
		// And now that we have a key in that struct for the table we're performing write actions on, let's init
		// the array for it's value.  The array will hold the WriteRequest instances that contain the puts.
		requestItems[pargs.tableName] = [];
		// For each item in the provided array parameter we need to create a PutItemRequest, however when done
		// in batch these PutItemRequest instances need to be wrapped, each one, in a WriteRequest.  Let's
		// iterate over the provided items to be put and package them up in their Java instances.
		for (var item in pargs.items)
		{
			// Create the WriteRequest
			var awsWriteRequest = createObject("java", "com.amazonaws.services.dynamodb.model.WriteRequest")
				.init()
				.withPutRequest(createObject("java", "com.amazonaws.services.dynamodb.model.PutRequest")
					.init()
					.withItem(struct_to_dynamo_map(item))
				);
			// Now append it to our batch array
			arrayAppend(requestItems[pargs.tableName], awsWriteRequest);
		}
		// Setup the request, but don't add any items to it yet.  That's done inside the while loop.
		awsBatchWriteItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.BatchWriteItemRequest").init();
		do {
			awsBatchWriteItemRequest.setRequestItems(requestItems);
			result = variables.awsDynamoDBClient.batchWriteItem(awsBatchWriteItemRequest);
			// Assign the remaining items that didn't get processed in this iteration of the loop
			// to the requestItems var that feeds back into the loop at the top.
			requestItems = result.getUnprocessedItems();
		} while (result.getUnprocessedItems().size() > 0);
		// Nothing to return
		return;
	}


	public any function getItem(
		required string tableName hint="Name of the table from which we are getting an item"
		, required Any hashKey hint="The numeric or string key identifier for the record you would like retrieved"
		, Any rangeKey hint="Optional, if defined it will be used in conjunction with the hashKey to identify the record that is to be retrieved"
		, required string fields)
	{
		// Set up a protected, sanitized version of the arguments scope
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["hashKey"] = trim(arguments.hashKey);
		if (structKeyExists(arguments, "rangeKey")) pargs["rangeKey"] = trim(arguments.rangeKey);

		// Initialize the key object that identifies the key, in term the AWS SDK understands
		var key = createObject("java", "com.amazonaws.services.dynamodb.model.Key")
			.init()
			.withHashKeyElement(createAttributeValue(pargs.hashKey));
		// If we have a rangeKey specified, add that to our key instance
		if (structKeyExists(pargs, "rangeKey"))
		{
			key.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
		}

		var get_item_request = createObject("java", "com.amazonaws.services.dynamodb.model.GetItemRequest").init()
			.withTableName(pargs.tableName)
			.withKey(key);
		var result = variables.awsDynamoDBClient.getItem(get_item_request);
		var item = result.getItem();

		// If the requested item was not found, our item var will now be null
		if (!isDefined("item"))
		{
			throw(type="API.AWS.DynamoDB.RecordNotFound", message="The record you're looking for with identifier '#pargs.hashKey#' cannot be found.");
		}
		// Return the item, converted into a native CFML struct
		return dynamo_to_struct_map(result.getItem());
	}


	public any function deleteItem(
		required string tableName hint="Name of the table from which a record is to be deleted."
		, required Any hashKey hint="Numeric or string key that identifies the record to be deleted"
		, Any rangeKey hint="Optional, if defined it will be used in conjunction with the hashKey to identify the record that is to be retrieved")
	{
		// Set up a protected, sanitized version of the arguments scope
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["hashKey"] = trim(arguments.hashKey);
		if (structKeyExists(arguments, "rangeKey")) pargs["rangeKey"] = trim(arguments.rangeKey);

		// Initialize the key object that identifies the key, in term the AWS SDK understands
		var key = createObject("java", "com.amazonaws.services.dynamodb.model.Key")
			.init()
			.withHashKeyElement(createAttributeValue(pargs.hashKey));
		// If we have a rangeKey specified, add that to our key instance
		if (structKeyExists(pargs, "rangeKey"))
		{
			key.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
		}
		// Let's setup the returnValues param to the delete request, which will instruct the request to return all the
		// attributes of the record as it existed prior to the delete.  This sets up the ability to make an UNDO, assuming
		// these attributes were cached or stored locally after the delete from DynamoDB.  They are accessible via the
		// result.getAttributes() method after the delete operation completes.
		var returnValues = createObject("java", "com.amazonaws.services.dynamodb.model.ReturnValue").ALL_OLD;
		// Now create the delete request
		var deleteItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.DeleteItemRequest")
			.init()
			.withTableName(trim(pargs.tableName))
			.withKey(key)
			.withReturnValues(returnValues);
		// Send the request in!
		var result = variables.awsDynamoDBClient.deleteItem(deleteItemRequest);
		// VALIDATION - if the getAttributes() method on the result returns null, then the items that was supposed to
		// be deleted didn't exist.  This doesn't really hurt anything, but it means this method wasn't able to complete
		// the request, so we need to throw an exception to be good programmers.
		var itemDeleted = result.getAttributes();
		if (isDefined("itemDeleted"))
		{
			// Convert the hashmap of AttributeValue instances into a CF struct for return
			var stItemDeleted = dynamo_to_struct_map(result.getAttributes());
		}
		else throw(type="API.AWS.DynamoDB.RecordNotFound", message="The record you tried to delete with identifier #pargs.hashKey# cannot be found, and was not deleted.");

		// Return the item that was deleted, since the AWS SDK sends it back to us
		return stItemDeleted;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Batch Delete Items
	* @hint Utilizes the batch delete capabilities of the AWS Java SDK.  All that's required to complete this operation is the name of the table and a list of keys.  Note that DynamoDB keys can be either a single string or numeric HashKey, or that in addition to a RangeKey.  This is why the items array parameter must contain structs that are made up of either a single 'hashKey' name/val, or both a 'hashKey' and a 'rangeKey' name/val pair.
	*/
	public Any function batchDeleteItems(
		required String tableName hint="Name of the table into which the provided data will be inserted as a record."
		, required Array items hint="Collection (array) of Structs that are each containing the necessary keys that identify records to be deleted from the specified table.")
	{
		// Make a sanitized version of arguments scoped values we will use
		var pargs = {
			"tableName" = trim(arguments.tableName),
			"items" = arguments.items
		};

		// If items is empty, return immediately.
		if (arrayLen(pargs.items) == 0) return;

		// Build the request items that ultimately feeds into the batch write item request
		var requestItems = {};
		// And now that we have a key in that struct for the table we're performing write actions on, let's init
		// the array for it's value.  The array will hold the WriteRequest instances that contain the puts.
		requestItems[pargs.tableName] = [];
		// For each item in the provided array parameter we need to create a PutItemRequest, however when done
		// in batch these PutItemRequest instances need to be wrapped, each one, in a WriteRequest.  Let's
		// iterate over the provided items to be put and package them up in their Java instances.
		for (var item in pargs.items)
		{
			// Create the WriteRequest
			var oWriteRequest = createObject("java", "com.amazonaws.services.dynamodb.model.WriteRequest")
				.init()
				.withDeleteRequest(createObject("java", "com.amazonaws.services.dynamodb.model.DeleteRequest")
					.init()
					.withKey(createKey(argumentcollection=item))
				);
			// Now append it to our batch array
			arrayAppend(requestItems[pargs.tableName], oWriteRequest);
		}

		// Create the instance of the batch write request, which is the final package that is sent into the awsDynamoDBClient Client
		batchWriteItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.BatchWriteItemRequest").init();

		do {
			// Assign the requestItems to the batch request here because we alter it at the bottom
			// of the while loop to be the remaining unprocessed items in the batch.
			batchWriteItemRequest.setRequestItems(requestItems);
			// Send in the request
			result = variables.awsDynamoDBClient.batchWriteItem(batchWriteItemRequest);
			// Assign the remaining items that didn't get processed in this iteration of the loop
			// to the requestItems var that feeds back into the loop at the top.
			requestItems = result.getUnprocessedItems();
		} while (result.getUnprocessedItems().size() > 0);
		// Nothing to return
		return;
	}


	public Array function queryTable(
		required String tableName hint="Name of the table to be queried.  Case sensitive."
		, required Any itemKey hint="String or numeric, the value of the hash key to match on the query"
		, String comparisonOperator hint="Must be one of the accepted comparison operators"
		, Array comparisonValues hint="Collection of one or two values to be compared. Two are used for operators such as BETWEEN.")
	{
		// Create private copy of arguments where we sanitize values
		var pargs = {};
		pargs.tableName = trim(arguments.tableName);
		pargs.itemKey = trim(arguments.itemKey);

		// Generate our key instance
		var key = createAttributeValue(pargs.itemKey);
		// Create the query request, using initial values for a plain hash key query
		var queryRequest = createObject("java", "com.amazonaws.services.dynamodb.model.QueryRequest")
			.init()
			.withTableName(trim(pargs.tableName))
			.withHashKeyValue(key);

		// Examine private arguments (pargs) to determine if we have a range key condition. Validation is factored
		// into a private function that does some careful checking to ensure everything is structured properly.
		if (hasValidRangeKeyCondition(arguments))
		{
			pargs.comparisonOperator = UCase(trim(arguments.comparisonOperator));
			pargs.comparisonValues = convertArrayToAttributeValues(arguments.comparisonValues);
			// Looks like we have one. Setup a condition that we can add to the query request
			var condition = createObject("java", "com.amazonaws.services.dynamodb.model.Condition")
				.init()
				.withComparisonOperator(pargs.comparisonOperator)
				.withAttributeValueList(pargs.comparisonValues);
			// Add the condition to the query request
			queryRequest.setRangeKeyCondition(condition);
		}

		var result = variables.awsDynamoDBClient.query(queryRequest);

		return dynamoItemCollectionToStructCollection(result.getItems());
	}


	public Array function scanTable(
		required String tableName hint="Name of table to be scanned.  Case sensitive."
		, Array conditions hint="Optional, a collection of condition structures to be used as condition filters on the resulting scan."
		, Struct start hint="Exclusive start key set, used for pagination. Must be a struct with a required key 'hashKey' and optional key 'rangeKey'."
		, Numeric limit hint="Limit on how many results to return, used for pagination")
	{
		// Create private copy of arguments where we sanitize values
		var pargs = {};
		pargs.tableName = trim(arguments.tableName);

		// Create the scan request
		var scanRequest = createObject("java", "com.amazonaws.services.dynamodb.model.ScanRequest")
			.init()
			.withTableName(pargs.tableName);
	
		// Examine the arguments scope for valid additional filter parameters
		if (structKeyExists(arguments, "conditions") && arrayLen(arguments.conditions))
		{
			var scanConditions = {};
			for (var cond in arguments.conditions)
			{
				var awsCondition = createObject("java", "com.amazonaws.services.dynamodb.model.Condition")
					.init()
					.withComparisonOperator(cond["comparisonOperator"])
					.withAttributeValueList(convertArrayToAttributeValues(cond["comparisonValues"]));
				scanConditions[cond["attributeName"]] = awsCondition;
			}
			scanRequest.setScanFilter(scanConditions);
		}
		// Check for a starting record for pagination
		if (structKeyExists(arguments, "start"))
		{
			var startKey = createObject("java", "com.amazonaws.services.dynamodb.model.Key")
				.init()
				.withHashKeyElement(createAttributeValue(arguments.start["hashKey"]));
			// Check to see if a range key was provided
			if (structKeyExists(arguments.start, "rangeKey"))
			{
				startKey.setRangeKeyElement(createAttributeValue(arguments.start["rangeKey"]));
			}
			scanRequest.setExclusiveStartKey(startKey);
		}
		// Check for a limiter on the size of the result set for paging result sets
		if (structKeyExists(arguments, "limit"))
		{
			scanRequest.setLimit(arguments.limit);
		}
		// Execute the scan
		var result = variables.awsDynamoDBClient.scan(scanRequest);
		// Return the transformed results in a CFML native format
		return dynamoItemCollectionToStructCollection(result.getItems());
	}



	/**

	PRIVATE METHODS

	**/	


	/**
	* @author Adam Bellas
	* @displayname DynamoDB to CFML Struct Converter
	* @output false
	* @hint Accepts the AWS SDK's GetItemResult instance and copies it's internal values out into a native CFML structure
	*/
	private Struct function dynamo_to_struct_map(
		required Struct itemAttributes hint="A hash map of com.amazonaws.services.dynamodb.model.AttributeValue instances")
	{
		// These are the methods we need to test against to see if the resulting value is defined
		var aMethodCheckList = ["getB","getBS","getN","getNS","getS","getSS"];
		// Initialize the return record struct
		var stRecord = {};
		// Iterate over the hash map (struct) keys in the result's item
		for (var prop in arguments.itemAttributes)
		{
			// Alias the value stored in that key to a local var
			var oProp = arguments.itemAttributes[prop];
			// Iterate over our list of methods to test
			for (var method in aMethodCheckList)
			{
				// Assign the return of the current method under test (MUT) to a var
				var test = evaluate("oProp.#method#()");
				// Check to see if the var has value.  ONLY ONE OF THE SIX WILL.
				if (isDefined("test"))
				{
					// Found one with value!  Drop it in our return struct and break the loop iteration over the methods
					stRecord[prop] = test;
					break;
				}
			}
		}
		// Return the populated CFML struct
		return stRecord;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Dynamo Item Collection to Struct Collection
	* @hint Converts an array collection of DynamoDB items (which are HashMap structs of AttributeValue instances) to a native CF array of structs.
	*/
	private Array function dynamoItemCollectionToStructCollection(
		required Array aItems hint="Collection of DynamoDB items, which are structs of AttributeValue instances")
	{
		var aReturn = [];
		for (item in arguments.aItems)
		{
			arrayAppend(aReturn, dynamo_to_struct_map(item));
		}
		return aReturn;
	}


	private any function struct_to_dynamo_map(required struct cf_structure){
		var dynamo_map = createObject("java","java.util.HashMap").init();
		var val = "";
		for (var key in arguments.cf_structure )
		{
			val = arguments.cf_structure[key];

			// Perform type detection tests
			if (isNumeric(val))
			{
				dynamo_map.put(
					"#key#", 
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withN(val)
				);
			}
			else if (isBinary(val))
			{
				// Binary objects have their own way of being dealt with
				dynamo_map.put(
					"#key#", 
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withB(val)
				);

			}
			else if (isArray(val))
			{
				// Arrays are adapted into Java sets, which are similar but not quite the same.  Regardless, DDB can
				// work with sets of strings or sets of numbers, so let's use the first item in the array to test for
				// numeric-ness.
				if (areAllValuesNumeric(val))
				{
					// So far so good.  Let's roll with a numeric set, but fail to a string set
					dynamo_map.put(
						"#key#",
						createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withNS(val)
					);
				}
				else if (areAllValuesBinary(val))
				{
					// So far so good.  Let's roll with a numeric set, but fail to a string set
					dynamo_map.put(
						"#key#",
						createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withBS(val)
					);
				}
				else
				{
					// Not numeric, use a string set
					dynamo_map.put(
						"#key#",
						createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withSS(val)
					);
				}
			}
			else
			{
				// It's neither numeric or an array, so let's treat it as a string
				dynamo_map.put(
					"#key#",
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withS("#val#")
				);
			}
		}
		return dynamo_map;
	}


	private Boolean function areAllValuesNumeric(
		required Array a hint="Array containing values we need to test for numericness")
	{
		// Iterate over array
		for (var item in arguments.a)
		{
			if (!isNumeric(item)) return false;
		}
		// If we made it this far, all the items in the array are numeric, so return true
		return true;
	}


	private Boolean function areAllValuesBinary(
		required Array a hint="Array containing values we need to test for binary-ness")
	{
		// Iterate over array
		for (var item in arguments.a)
		{
			if (!isBinary(item)) return false;
		}
		// If we made it this far, all the items in the array are binary, so return true
		return true;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Create Item Key
	* @hint Converts a numeric or string attribute value (detects the type) and creates an appropriately infused instance of the AWS SDK AttributeValue class that can then be used against other methods that target single records in any table (i.e. getItem, deleteItem, etc.)
	*/
	private Any function createAttributeValue(
		required Any itemValue hint="Numeric or string value that needs to be converted into a valid AttributeValue instance for DynamoDB")
	{
		// We need to detect whether or not a string or numeric key has been passed in so we can properly
		// detect the kind of AttributeValue to create.
		var oAttributeValue = createObject("java", "com.amazonaws.services.dynamodb.model.AttributeValue").init();
		if (isNumeric(arguments.itemValue)) {
			// Set the N value
			oAttributeValue.setN(arguments.itemValue);
		}
		else {
			// Set the S value, assuming non-numeric values to be strings
			// TODO: Apply further validation on arguments.itemValue to ensure it's either string or numeric. We shouldn't allow someone to shove an array or something in there and muck up the works.
			if (isDate(arguments.itemValue)) oAttributeValue.setS(dateFormat(arguments.itemValue, "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));
			else oAttributeValue.setS(arguments.itemValue);
		}
		return oAttributeValue;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Convert Array to Attribute Values
	* @hint Converts every value inside an array and creates a corresponding AttributeValue instance (from the AWS SDK), and returns a new array with those instances.
	*/
	private Array function convertArrayToAttributeValues(
		required Array aOriginal hint="Array of values. The values will be converted to AWS SDK AttributeValue instances.")
	{
		var aReturn = [];
		for (var val in arguments.aOriginal)
		{
			arrayAppend(aReturn, createAttributeValue(val));
		}
		return aReturn;
	}


	private Boolean function hasValidRangeKeyCondition(
		required Struct aArgs hint="Passed by reference array containing arguments that are to be validated as DynamoDB query conditions.")
	{
		// Make sure the two necessary arguments have been provided
		if (!isDefined("aArgs.comparisonOperator") || !isDefined("aArgs.comparisonValues"))
		{
			// Missing what it takes to perform a range key condition, so return false.
			return false;
		}
		// Instantiate the enumerator for comparison operators
		var comparisonOperatorEnum = createObject("java", "com.amazonaws.services.dynamodb.model.ComparisonOperator");
		// Check the provided operator against the enumerator
		var bFound = false;
		for (var op in comparisonOperatorEnum.values())
		{
			if (op.toString() == aArgs.comparisonOperator)
			{
				bFound = true;
				break;
			}
		}
		if (!bFound)
		{
			// Throw on invalid operator
			throw(type="API.AWS.DynamoDB.InvalidParameter", message="An invalid comparison operator, #aArgs.comparisonOperator#, was provided.");
		}
		// Return true if no throws
		return true;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Create Key
	* @hint Helper function that turns CFML native string or numeric key ID's into bonefide AWS SDK Java Key instance
	*/
	private Any function createKey(
		required Any hashKey hint="Required, used to initialize a proper key instance that can identify a record in a DynamoDB table"
		, Any rangeKey hint="Optional, a string or numeric that completes a key instance that can identify a record in a DynamoDB dual key table")
	{
		// Make a sanitized version of arguments scoped values we will use
		var pargs = {};
		pargs["hashKey"] = trim(arguments.hashKey);
		if (structKeyExists(arguments, "rangeKey")) pargs["rangeKey"] = trim(arguments.rangeKey);

		// Initialize the key object that identifies the key, in term the AWS SDK understands
		var key = createObject("java", "com.amazonaws.services.dynamodb.model.Key")
			.init()
			.withHashKeyElement(createAttributeValue(pargs.hashKey));
		// If we have a rangeKey specified, add that to our key instance
		if (structKeyExists(pargs, "rangeKey"))
		{
			key.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
		}

		// Return the AWS SDK key instance
		return key;
	}



}