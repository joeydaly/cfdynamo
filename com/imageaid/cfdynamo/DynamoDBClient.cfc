/**
* @displayname CFML Amazon AWS DynamoDB Client
* @hint I handle interactions with an Amazon SDK DynamoDB instance.  To use me, you must have the Amazon SDK jar file in the classpath.
*/
component
	accessors="true"
	output="false"
	singleton="true"

{



	/**
	* @hint Variable to contain the singleton instance of the AWS SDK Client
	*/
	property name="awsDynamoDBClient" type="Any";


	/**

	CONSTRUCTOR

	**/


	/**
	* @displayName Initialize
	* @hint Returns an initialized instance of this class.  It is intended to be instantiated and used most optimally as a singleton.
	*/
	public DynamoDBClient function init(
		required String awsKey
		,required String awsSecret
		,Boolean useHTTPS=false
		,String awsZone="us-east-1")
	{
		// Cleanup and prepare the initializstion parameters
		var local.awsKey = trim(arguments.awsKey);
		var local.awsSecret = trim(arguments.awsSecret);
		var local.awsZone = trim(arguments.awsZone);
		var local.useHTTPS = trim(arguments.useHTTPS);

		// Vaildate credentials, make sure they're not empty or something silly like that.
		validateCredentials(awsKey=local.awsKey, awsSecret=local.awsSecret);

		// Initialize the Java AWS SDK DynamoDB Client that is used in all core functions
		variables.awsDynamoDBClient = initClient(awsKey=local.awsKey, awsSecret=local.awsSecret);

		// Initialize the endpoint (it can vary based on our SSL security parameter)
		initEndpoint(
			useHTTPS=local.useHTTPS
			,awsZone=local.awsZone
			,awsDynamoDBClient=variables.awsDynamoDBClient);

		return this;
	}


	/**
	* @displayName Validate Credentials
	* @hint Ensure the supplied credentials are proper enough to bother sending upstream for authentication
	*/
	private Void function validateCredentials(
		required String awsKey
		,required String awsSecret)
	{
		// Make sure they are not empty strings
		if (len(arguments.awsKey) == 0) throw(message="The AWSKey setting was not properly injected or is of zero-length.");
		if (len(arguments.awsSecret) == 0) throw(message="The AWSKey setting was not properly injected or is of zero-length.");
		// TODO: Examine AWS API to see if there are other validations we can perform like min-length, etc.
	}


	/**
	* @displayName Initialize Client
	* @hint Initializes the AWS Java SDK Client, as a singleton, to be used by all the core functons of this library
	*/
	private Any function initClient(
		required String awsKey
		,required String awsSecret)
	{
		var awsCredentials = createObject("java","com.amazonaws.auth.BasicAWSCredentials").init(arguments.awsKey, arguments.awsSecret);
		var awsDynamoDBClient = createObject("java","com.amazonaws.services.dynamodb.AmazonDynamoDBClient").init(awsCredentials);
		return awsDynamoDBClient;
	}


	/**
	* @displayName Initialize Endpoint
	* @hint Examines the library's initialization parameter and sets a secure or non-secure host endpoint for the SDK to utilize.
	*/
	private Void function initEndpoint(
		required Boolean useHTTPS
		,required String awsZone
		,required Any awsDynamoDBClient)
	{
		/*
			There are two possible endpoints for each availability zone, one that is secure and the other that is not.
			The URL pattern is as follows, using the us-east-1 availability zone as an example:

			http://dynamodb.us-east-1.amazonaws.com
			https://dynamodb.us-east-1.amazonaws.com

			So based on the incoming useHTTPS parameter construct the endpoint string and assign it to the client.

			// TODO: See if the AWS API provides a more concrete way to determine the endpoint. This feels shady.
		*/
		if (arguments.useHTTPS)
		{
			arguments.awsDynamoDBClient.setEndpoint("https://dynamodb.#arguments.awsZone#.amazonaws.com");
		}
		else
		{
			// Do nothing, the default setting is the non-secure, this is just an override if secure is desired.
		}
		return;
	}


	/**

	CORE FUNCTIONS

	**/


	/**
	* @displayName Create Table
	* @hint Creates a new DynamoDB table. The return is an instance of the TableDescription AWS Java class.  Use the toString method on it for simple info about the table that was just created.
	*/
	public Any function createTable(
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
        	var awsCreateTableResult = variables.awsDynamoDBClient.createTable(awsTableRequest);
        }
        catch(Any e) {
        	writeLog(type="Error",text="Error during createTable: #e.type# :: #e.message#", file="dynamodb");
        	rethrow;
        }
		return convertAWSTableDescriptionToStruct(awsCreateTableResult.getTableDescription());
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

		// Return the result as a struct
		return convertAWSTableDescriptionToStruct(awsTableDescription);
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
	* @hint Deletes the specified table. Use with care, there is no confirmation for this operation.  All data will be lost! Returns the name of the table that was successfully deleted.
	*/
	public Struct function deleteTable(
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
        	var awsDeleteTableResult = variables.awsDynamoDBClient.deleteTable(awsDeleteTableRequest);
        }
        catch(Any e) {
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb");
        	rethrow;
        }
        // Pull the table description out of the result and convert it to a struct
        var stDeletedTableInfo = convertAWSTableDescriptionToStruct(awsDeleteTableResult.getTableDescription());
        // Return our info struct
        return stDeletedTableInfo;
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
	public Struct function putItem(
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
			.withItem(struct_to_dynamo_map(pargs.item))
			.withReturnValues(createObject("java", "com.amazonaws.services.dynamodb.model.ReturnValue").ALL_OLD);
		try {
			var awsPutItemResult = variables.awsDynamoDBClient.putItem(awsPutItemRequest);
		} catch(any e)
		{
			switch(e.message)
			{
				case 'Requested resource not found':
					throw(message="AWS Threw a  Requested resource not found (com.amazonaws.services.dynamodb.model.ResourceNotFoundException : ResourceNotFoundException) Exception",detail="Please verify the table #arguments.tableName# exists in DynamoDB.");
				break;
				default:
					rethrow;
				break;
			}
		}

		// TODO: It could be beneficial here to log the consumed capacity, since it's present in the result

		// Return the old item that was replaced by the put. Note that this will be null if it was a new record, and so the struct may be empty
		var oldItem = awsPutItemResult.getAttributes();
		if (isDefined("oldItem")) return dynamo_to_struct_map(awsPutItemResult.getAttributes());
		else return {};
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
		// Don't bother with the call in any way if we don't have at least one item in the item collection
		if (arrayLen(arguments.items) < 1) {
			throw(type="API.InvalidParameters", message="The items collection passed to batchPutItems must contain at least one item.");
		}
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


	/**
	* @displayname Get Item
	* @hint Retrieves a single record, identified by it's primary key, from the specified table.  Customized return fields are supported.
	*/
	public any function getItem(
		required string tableName hint="Name of the table from which we are getting an item"
		, required Any hashKey hint="The numeric or string key identifier for the record you would like retrieved"
		, Any rangeKey hint="Optional, if defined it will be used in conjunction with the hashKey to identify the record that is to be retrieved"
		, String attributeNames hint="Optional comma separated list of attribute names. If attribute names are not specified then all attributes will be returned. If some attributes are not found, they will not appear in the result.")
	{
		request.logger(variables.logger,'info','getItem:Logging HashKey',arguments.hashKey);
		try {
			// Set up a protected, sanitized version of the arguments scope
			var pargs = {};
			pargs["tableName"] = trim(arguments.tableName);
			pargs["hashKey"] = trim(arguments.hashKey);
			if (structKeyExists(arguments, "rangeKey")) pargs["rangeKey"] = trim(arguments.rangeKey);
			if (structKeyExists(arguments, "attributeNames")) pargs["attributeNames"] = arguments.attributeNames;

			// Initialize the key object that identifies the key, in term the AWS SDK understands
			var awsKey = createKey(pargs["hashKey"]);

			// If we have a rangeKey specified, add that to our key instance
			if (structKeyExists(pargs, "rangeKey"))
			{
				awsKey.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
			}
			// Create our get item request that will be sent to the AWS services
			var awsGetItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.GetItemRequest").init()
				.withTableName(pargs.tableName)
				.withKey(awsKey);
			// If attribute names were specified for the return, set those in the get item request
			if (structKeyExists(pargs, "attributeNames") && listLen(pargs["attributeNames"]) > 0)
			{
				awsGetItemRequest.setAttributesToGet(listToArray(pargs["attributeNames"]));
			}
			var result = variables.awsDynamoDBClient.getItem(awsGetItemRequest);
			var item = result.getItem();

			// If the requested item was not found, our item var will now be null
			if (!isDefined("item"))
			{
				// TODO: ideally, Hoth would be tracking these issues.
				request.logger(variables.logger,'info','getItem:API.AWS.DynamoDB.RecordNotFound. HashKey',arguments.hashKey);
				throw(type="API.AWS.DynamoDB.RecordNotFound", message="The record you're looking for with identifier '#pargs.hashKey#' cannot be found.");
			}
			request.logger(variables.logger,'info','getItem:Item found',arguments.hashKey);
			// Return the item, converted into a native CFML struct
		} catch (any e) {
			writeDump(var=arguments);
			writeDump(var=e,abort=1,label='DynamoDBClient.getItem()');
		}
		return dynamo_to_struct_map(item);
	}


	public void function batchGet(
		required shared.model.AWS.DynamoDBBatchGetHelper DynamoDBBatchGetHelper
	){
		var AWSResult = [];
		var BatchGetItemsRequest = DynamoDBBatchGetHelper.getBatchGetItemRequest(); // Get a reference to this section of the object.

		for(batch in BatchGetItemsRequest){
			var leftoverKeys = duplicate(batch.keys); // Used for tracking.
			do {
				var AWSResult = variables.awsDynamoDBClient.batchGetItem(batch.ItemRequest);
				var responses = AWSResult.getResponses();

				for(var reponse in responses){
					try{
						for(var item in responses[reponse].getItems()){

							var id = item['id'].getS();
							var content = item['content'].getS();
							// Add data to the helper records.
							DynamoDBBatchGetHelper.addRecord( batch.TableName, id, content );

							var position = batch.keys.indexOf(id);
							if(position >= 0){
								arrayDeleteAt(leftoverKeys, incrementValue(position)); // Holy crap, we're still using array[1] as a starting point in cfml?!
							}
						}
					}catch (any e){
						// blergh? Why doesn't the response object have something freaking useful like, hasRecord() or something? :P
					};
					// TODO: TR - Handle AWSResult.getUnprocessedKeys() correctly.
				}
			} while (AWSResult.getUnprocessedKeys().size() > 0);

			if(arrayLen(leftoverKeys))
			{
				DynamoDBBatchGetHelper.Omit(batch.TableName, leftoverKeys); // report bad keys to DynamoDBBatchGetHelper
				request.logger(variables.logger,'info','batchGet unable to obtain these records.',batch.keys);
			}
		}

		return;
	}

	/**
	* @displayname Delete Item
	* @hint Deletes the item, specified by a primary key and optionally a range key, from the specified table. Returns a copy of the item that was deleted so that undo may be implemented in the supporting application.
	*/
	public any function deleteItem(
		required String tableName hint="Name of the table from which a record is to be deleted."
		, required Any hashKey hint="Numeric or string key that identifies the record to be deleted"
		, Any rangeKey hint="Optional, if defined it will be used in conjunction with the hashKey to identify the record that is to be retrieved")
	{
		// Set up a protected, sanitized version of the arguments scope
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["hashKey"] = trim(arguments.hashKey);
		if (structKeyExists(arguments, "rangeKey")) pargs["rangeKey"] = trim(arguments.rangeKey);

		// Initialize the key object that identifies the key, in term the AWS SDK understands
		var awsKey = createKey(pargs["hashKey"]);

		// If we have a rangeKey specified, add that to our key instance
		if (structKeyExists(pargs, "rangeKey"))
		{
			awsKey.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
		}
		// Let's setup the returnValues param to the delete request, which will instruct the request to return all the
		// attributes of the record as it existed prior to the delete.  This sets up the ability to make an UNDO, assuming
		// these attributes were cached or stored locally after the delete from DynamoDB.  They are accessible via the
		// result.getAttributes() method after the delete operation completes.
		var returnValues = createObject("java", "com.amazonaws.services.dynamodb.model.ReturnValue").ALL_OLD;
		// Now create the delete request
		var awsDeleteItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.DeleteItemRequest")
			.init()
			.withTableName(pargs.tableName)
			.withKey(awsKey)
			.withReturnValues(returnValues);
		// Send the request in!
		var result = variables.awsDynamoDBClient.deleteItem(awsDeleteItemRequest);
		// VALIDATION - if the getAttributes() method on the result returns null, then the items that was supposed to
		// be deleted didn't exist.  This doesn't really hurt anything, but it means this method wasn't able to complete
		// the request, so we need to throw an exception to be good programmers.
		var itemDeleted = result.getAttributes();
		// Make sure we have a deleted item that returned
		if (!isDefined("itemDeleted"))
		{
			// There's nothing there, so what we tried to delete was never found.  Throw an exception.
			throw(type="API.AWS.DynamoDB.RecordNotFound", message="The record you tried to delete with identifier #pargs.hashKey# cannot be found, and was not deleted.");
		}
		// Convert the hashmap of AttributeValue instances into a CF struct for return
		var stItemDeleted = dynamo_to_struct_map(result.getAttributes());
		// Return the item that was deleted, since the AWS SDK sends it back to us
		return stItemDeleted;
	}


	/**
	* @displayname Batch Delete Items
	* @hint Utilizes the batch delete capabilities of the AWS Java SDK.  All that's required to complete this operation is the name of the table and a list of keys.  Note that DynamoDB keys can be either a single string or numeric HashKey, or that in addition to a RangeKey.  This is why the items array parameter must contain structs that are made up of either a single 'hashKey' name/val, or both a 'hashKey' and a 'rangeKey' name/val pair.
	*/
	public Any function batchDeleteItems(
		required String tableName hint="Name of the table into which the provided data will be inserted as a record."
		, required Array items hint="Collection (array) of Structs that are each containing the necessary keys that identify records to be deleted from the specified table.")
	{
		// Don't bother with the call in any way if we don't have at least one item in the item collection
		if (arrayLen(arguments.items) < 1) {
			throw(type="API.InvalidParameters", message="The items collection passed to batchDeleteItems must contain at least one item.");
		}
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
			var awsWriteRequest = createObject("java", "com.amazonaws.services.dynamodb.model.WriteRequest")
				.init()
				.withDeleteRequest(createObject("java", "com.amazonaws.services.dynamodb.model.DeleteRequest")
					.init()
					.withKey(createKey(argumentcollection=item))
				);
			// Now append it to our batch array
			arrayAppend(requestItems[pargs.tableName], awsWriteRequest);
		}

		// Create the instance of the batch write request, which is the final package that is sent into the awsDynamoDBClient Client
		awsBatchWriteItemRequest = createObject("java", "com.amazonaws.services.dynamodb.model.BatchWriteItemRequest").init();

		do {
			// Assign the requestItems to the batch request here because we alter it at the bottom
			// of the while loop to be the remaining unprocessed items in the batch.
			awsBatchWriteItemRequest.setRequestItems(requestItems);
			// Send in the request
			result = variables.awsDynamoDBClient.batchWriteItem(awsBatchWriteItemRequest);
			// Assign the remaining items that didn't get processed in this iteration of the loop
			// to the requestItems var that feeds back into the loop at the top.
			requestItems = result.getUnprocessedItems();
		} while (result.getUnprocessedItems().size() > 0);
		// Nothing to return
		return;
	}


	/**
	* @displayname Query Table
	* @hint Queries a DynamoDB table specified.  Uses the hashKey or the hashKey and rangeKey criteria. You can query a table only if it has a composite primary key, that is, a primary that is composed of both a hash and range attribute.
	*/
	public Array function queryTable(
		required String tableName hint="Name of the table to be queried.  Case sensitive."
		, required Any hashKey hint="String or numeric, the value of the hash key to match on the query"
		, String comparisonOperator hint="Must be one of the accepted comparison operators"
		, Array comparisonValues hint="Collection of one or two values to be compared. Two are used for operators such as BETWEEN."
		, Struct startKey hint="Optional. If specified, must include 'hashKey' and 'rangeKey' keys, with specified values for those to match the record in the result set to start the pagination from."
		, Numeric limit=50 hint="Optional, defaults to 50. Specifies the number of items to be returned.")
	{
		// Create private copy of arguments where we sanitize values
		var pargs = {};
		pargs["tableName"] = trim(arguments.tableName);
		pargs["hashKey"] = trim(arguments.hashKey);
		if (structKeyExists(arguments, "comparisonOperator")) pargs["comparisonOperator"] = arguments.comparisonOperator;
		if (structKeyExists(arguments, "comparisonValues")) pargs["comparisonValues"] = arguments.comparisonValues;
		if (structKeyExists(arguments, "startKey")) pargs["startKey"] = arguments.startKey;
		pargs["limit"] = arguments.limit;

		// Create the query request, using initial values for a plain hash key query
		var awsQueryRequest = createObject("java", "com.amazonaws.services.dynamodb.model.QueryRequest")
			.init()
			.withTableName(pargs.tableName)
			.withHashKeyValue(createAttributeValue(pargs.hashKey))
			.withLimit(pargs["limit"]);

		// Examine private arguments (pargs) to determine if we have a range key condition. Validation is factored
		// into a private function that does some careful checking to ensure everything is structured properly.
		if (hasValidRangeKeyCondition(arguments))
		{
			pargs.comparisonOperator = UCase(trim(arguments.comparisonOperator));
			pargs.comparisonValues = convertArrayToAttributeValues(arguments.comparisonValues);
			// Looks like we have one. Setup a condition that we can add to the query request
			var awsCondition = createObject("java", "com.amazonaws.services.dynamodb.model.Condition")
				.init()
				.withComparisonOperator(pargs.comparisonOperator)
				.withAttributeValueList(pargs.comparisonValues);
			// Add the condition to the query request
			awsQueryRequest.setRangeKeyCondition(awsCondition);
		}

		var result = variables.awsDynamoDBClient.query(awsQueryRequest);

		return dynamoItemCollectionToStructCollection(result.getItems());
	}


	/**
	* @displayname Scan Table
	* @hint Scans (explore/read) the specified table. This is directly pulling in records from the table with filtering.
	*/
	public Array function scanTable(
		required String tableName hint="Name of table to be scanned.  Case sensitive."
		, Array conditions hint="Optional, a collection of condition structures to be used as condition filters on the resulting scan."
		, Struct startKey hint="Exclusive start key set, used for pagination. Must be a struct with a required key 'hashKey' and optional key 'rangeKey'."
		, Numeric limit hint="Limit on how many results to return, used for pagination")
	{
		// Create private copy of arguments where we sanitize values
		var pargs = {};
		pargs.tableName = trim(arguments.tableName);
		if (structKeyExists(arguments, "conditions")) pargs["conditions"] = arguments.conditions;
		if (structKeyExists(arguments, "startKey")) pargs["startKey"] = duplicate(arguments.startKey);
		if (structKeyExists(arguments, "limit")) pargs["limit"] = arguments.limit;

		// Create the scan request
		var awsScanRequest = createObject("java", "com.amazonaws.services.dynamodb.model.ScanRequest")
			.init()
			.withTableName(pargs.tableName);

		// Examine the arguments scope for valid additional filter parameters
		if (structKeyExists(pargs, "conditions") && arrayLen(pargs.conditions))
		{
			var scanConditions = {};
			for (var cond in pargs.conditions)
			{
				var awsCondition = createObject("java", "com.amazonaws.services.dynamodb.model.Condition")
					.init()
					.withComparisonOperator(cond["comparisonOperator"])
					.withAttributeValueList(convertArrayToAttributeValues(cond["comparisonValues"]));
				scanConditions[cond["attributeName"]] = awsCondition;
			}
			awsScanRequest.setScanFilter(scanConditions);
		}
		// Check for a starting record for pagination
		if (structKeyExists(pargs, "startKey"))
		{
			var awsKey = createKey(pargs.startKey["hashKey"]);
			// Check to see if a range key was provided
			if (structKeyExists(pargs.startKey, "rangeKey"))
			{
				awsKey.setRangeKeyElement(createAttributeValue(pargs.startKey["rangeKey"]));
			}
			awsScanRequest.setExclusiveKey(awsKey);
		}
		// Check for a limiter on the size of the result set for paging result sets
		if (structKeyExists(pargs, "limit"))
		{
			awsScanRequest.setLimit(createObject("java", "java.lang.Integer").init(pargs.limit));
		}

		// Execute the scan
		var result = variables.awsDynamoDBClient.scan(awsScanRequest);
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


	public Any function struct_to_dynamo_map(required struct cf_structure) {
		var dynamo_map = createObject("java","java.util.HashMap").init();
		for (var key in arguments.cf_structure )
		{
			try {
				// Create an AttributeValue instance and put it into the hash map
				var oAV = createAttributeValue(arguments.cf_structure[key]);
				dynamo_map.put("#key#", oAV);
			}
			catch("API.DataMissing" e) {
				// No need to panic. This exception coming from the createAttributeValue function simply means
				// it was given an empty string and that's not allowed with AttributeValue instances. Ignore this.
			}
			catch(Any e) {
				throw(type="API.DataTranslationError", message="DynamoDBClient: AWS Attribute Mapping Issue. Key #key# with value '#serializeJSON(arguments.cf_structure[key])#' fails. Accepted types: Strings, Numerics, Arrays", detail="AWS SDK Exception: #e.type# :: #e.message# :: #e.detail#");
			}
		}
		return dynamo_map;
	}


	/**
	* @author Adam Bellas
	* @output false
	* @displayname Create Item Key
	* @hint Converts a numeric or string attribute value (detects the type) and creates an appropriately infused instance of the AWS SDK AttributeValue class that can then be used against other methods that target single records in any table (i.e. getItem, deleteItem, etc.)
	*/
	private Any function createAttributeValue(
		required Any itemValue hint="Struct, Array, Binary, Numeric or String value that needs to be converted into a valid AttributeValue instance for DynamoDB")
	{
		// We need to detect whether or not a string or numeric key has been passed in so we can properly
		// detect the kind of AttributeValue to create.
		var awsAttributeValue = createObject("java", "com.amazonaws.services.dynamodb.model.AttributeValue").init();
		//....................................................................................
		//							Perform type detection tests
		//....................................................................................
		// Start by checking to see if our current value is an embedded struct, which typically indicates
		// that the key stores a sub-entity instance (e.g. a Resource might have an embedded Product).
		// We'll rip out the uuid from that sub object and embed that in the key in place of the struct.
		if (isStruct(itemValue)) {
			if (StructIsEmpty(itemValue)) {
				throw(type="API.DataMissing", message="A DynamoDB AttributeValue will not allow empty values. An empty structure was submitted to be converted into an AttributeValue instance.", detail="This is more of a warning than an error, however it is thrown from the createAttributeValue function and thus defines an exception during the mission to provide what was requested.  Calling code should handle this scenario appropriately.");
			}
			// We know we have a struct, but not sure if it is an entity yet. Check for uuid.
			if (structKeyExists(itemValue, "uuid")) {
				// Now it's official.  We have an entity. Put the uuid in this struct's place
				awsAttributeValue.setS(javaCast("string", itemValue["uuid"]));
			} else {
				// Okay, it's a struct, but not an entity. We don't want to lose it, so to be careful with
				// our data let's serialize it into JSON and store it as a string. Not optimal, but safe.
				awsAttributeValue.setS(javaCast("string", serializeJSON(itemValue)));
			}
		}
		else if (isArray(itemValue))
		{
			if (arrayLen(itemValue) == 0) {
				throw(type="API.DataMissing", message="A DynamoDB AttributeValue will not allow empty values. An empty array was submitted to be converted into an AttributeValue instance.", detail="This is more of a warning than an error, however it is thrown from the createAttributeValue function and thus defines an exception during the mission to provide what was requested.  Calling code should handle this scenario appropriately.");
			}
			// Arrays are adapted into Java sets, which are similar but not quite the same.  Regardless, DDB can
			// work with sets of strings or sets of numbers, so let's use the first item in the array to test for
			// numeric-ness.
			if (areAllValuesNumeric(itemValue)) {
				// So far so good.  Let's roll with a numeric set, but fail to a string set
				awsAttributeValue.setNS(itemValue);
			}
			else if (areAllValuesBinary(itemValue)) {
				// So far so good.  Let's roll with a binary set, but fail to a string set
				awsAttributeValue.setBS(itemValue);
			}
			else {
				// Not numeric, use a string set
				awsAttributeValue.setSS(itemValue);
			}
		}
		else if (isBinary(itemValue)) {
			// Binary objects have their own way of being dealt with
			awsAttributeValue.setB(itemValue);
		}
		// Now check for a numeric value.  Be careful here and don't let the AWS SDK fool you.  Even
		// though the type is numeric, the AWS SDK will cast this as a string for transport to the service.
		else if (isNumeric(arguments.itemValue)) {
			// Set the N value
			awsAttributeValue.setN(javaCast("string", arguments.itemValue));
		}
		else {
			// THE CATCH-ALL - Set the S value, assuming anything that hasn't been identified as another type is a string.
			// NOTE: The AWS AttributeValue class doesn't allow empty strings.  Throw an exception if it's empty.
			if (len(trim(arguments.itemValue)) == 0) {
				throw(type="API.DataMissing", message="A DynamoDB AttributeValue will not allow empty string values, which is what was submitted to be converted into an AttributeValue instance.", detail="This is more of a warning than an error, however it is thrown from the createAttributeValue function and thus defines an exception during the mission to provide what was requested.  Calling code should handle this scenario appropriately.");
			}
			// Add in some special date handling.  We will be using UTC style date strings in the DB
			// TODO: If this is a date, shouldn't it be converted to UTC time first?
			if (isDate(arguments.itemValue)) awsAttributeValue.setS(
				dateFormat(arguments.itemValue, "yyyy-mm-dd")
				& 'T'
				& timeFormat(arguments.itemValue, "HH:mm:ss.SSS")
				& 'Z'
			);
			else awsAttributeValue.setS(javaCast("string", arguments.itemValue));
		}
		return awsAttributeValue;
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
		var awsComparisonOperator = createObject("java", "com.amazonaws.services.dynamodb.model.ComparisonOperator");
		// Check the provided operator against the enumerator
		var bFound = false;
		for (var op in awsComparisonOperator.values())
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
		var awsKey = createObject("java", "com.amazonaws.services.dynamodb.model.Key")
			.init()
			.withHashKeyElement(createAttributeValue(pargs.hashKey));
		// If we have a rangeKey specified, add that to our key instance
		if (structKeyExists(pargs, "rangeKey"))
		{
			awsKey.setRangeKeyElement(createAttributeValue(pargs.rangeKey));
		}

		// Return the AWS SDK key instance
		return awsKey;
	}


    private Struct function convertAWSTableDescriptionToStruct(
    	required Any awsTableDescription)
    {
        // The TableDescription instance is messy for ColdFusion so let's map
        // it to a basic struct with the properties of the table as keys
        var AWSTableDesc = arguments.awsTableDescription;
        var KeySchema = AWSTableDesc.getKeySchema();
        var readCapacity = AWSTableDesc.getProvisionedThroughput().getReadCapacityUnits();
        var writeCapacity = AWSTableDesc.getProvisionedThroughput().getWriteCapacityUnits();

		var tableInfo = {
			'tableName' = AWSTableDesc.getTableName()
			,'creationDateTime' = AWSTableDesc.getCreationDateTime()
			,'itemCount' = AWSTableDesc.getItemCount()
			,'TableStatus' =  AWSTableDesc.getTableStatus()
			,'hashCode' =  AWSTableDesc.hashCode()
			,'ProvisionedThroughput' = {
					'read' = (isDefined("readCapacity")) ? AWSTableDesc.getProvisionedThroughput().getReadCapacityUnits() : "undefined"
					,'write' = (isDefined("writeCapacity")) ? writeCapacity : "undefined"
			}
			,'keys' = {
				'hashKey' = {
					'name' = KeySchema.getHashKeyElement().getAttributeName()
					,'type' = KeySchema.getHashKeyElement().getAttributeType()
				}
			}
		};

		try{
			tableInfo['keys']['RangeKey'] = KeySchema.getRangeKeyElement().getAttributeName();
			tableInfo['keys']['RangeKey'] = KeySchema.getRangeKeyElement().getAttributeType();
		}catch (any e){
			// Range key doesn't exist.
		}

		return tableInfo;
    }

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


	private Array function listConditionOperators() {
		return ["BEGINS_WITH", "BETWEEN", "CONTAINS", "EQ", "GE", "GT", "IN", "LE", "LT", "NE", "NOT_CONTAINS", "NOT_NULL", "NULL"];
	}

}