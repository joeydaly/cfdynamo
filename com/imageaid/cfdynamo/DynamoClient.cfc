component accessors="true" alias="com.imageaid.cfdynamo.DynamoClient" displayname="DynamoClient" hint="I handle interactions with an Amazon DynamoDB instance"{
	
	property name="aws_key" type="string" hint="The AWS Key";
	property name="aws_secret" type="string" hint="The AWS Secret";
	property name="aws_creds" type="object";
	property name="aws_dynamodb" type="object";
	
	variables.aws_key = "";
	variables.aws_secret = "";

	public DynamoClient function init(required string aws_key, required string aws_secret){
		variables.aws_key = trim(arguments.aws_key);
		variables.aws_secret = trim(arguments.aws_secret);
		variables.aws_creds = createObject("java","com.amazonaws.auth.BasicAWSCredentials").init(variables.aws_key, variables.aws_secret);
		variables.aws_dynamodb = createObject("java","com.amazonaws.services.dynamodb.AmazonDynamoDBClient").init(aws_creds);
		return this;
	}
	
	public boolean function create_table(
		required string table_name, required string pk_name='id', required string pk_type = 'hash', required string pk_value_type='int',
		string pk_range_name, string pk_range_value_type, numeric read_capacity=5, numeric write_capacity=5
	){
		var result = true;
		var read_capacity_casted = JavaCast("long",arguments.read_capacity);
		var write_capacity_casted = JavaCast("long",arguments.write_capacity);
		var primary_key_type = ( lcase(trim(arguments.pk_value_type)) == 'int' ? "N" : "S" );
		var hash_key = createObject(
			"java",
			"com.amazonaws.services.dynamodb.model.KeySchemaElement"
			).init().withAttributeName("#arguments.pk_name#").withAttributeType("#primary_key_type#");
		var key_schema = createObject("java","com.amazonaws.services.dynamodb.model.KeySchema").init(hash_key);
        var provisioned_throughput = createObject("java","com.amazonaws.services.dynamodb.model.ProvisionedThroughput").init()
            .withReadCapacityUnits(#read_capacity_casted#)
            .withWriteCapacityUnits(#write_capacity_casted#);
        var table_request = createObject(
        	"java",
        	"com.amazonaws.services.dynamodb.model.CreateTableRequest"
        	).init().withTableName(trim(arguments.table_name)).withKeySchema(key_schema).withProvisionedThroughput(provisioned_throughput);
        
        try{
        	variables.aws_dynamodb.createTable(table_request);
        }
        catch(Any e){
        	result = false;
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb.log");
        }
		return result;
	}
	
	public boolean function update_table(required string table_name, required numeric read_capacity, required numeric write_capacity){
		var result = true;
		var call_result = "";
		var read_capacity_casted = JavaCast("long",arguments.read_capacity);
		var write_capacity_casted = JavaCast("long",arguments.write_capacity);
		var provisioned_throughput = createObject("java","com.amazonaws.services.dynamodb.model.ProvisionedThroughput").init()
            .withReadCapacityUnits(#read_capacity_casted#)
            .withWriteCapacityUnits(#write_capacity_casted#);
		var update_table_request = createObject(
			"java", 
			"com.amazonaws.services.dynamodb.model.UpdateTableRequest"
			).init().withTableName(trim(arguments.table_name)).withProvisionedThroughput(provisioned_throughput);
        
        try{
        	call_result = variables.aws_dynamodb.updateTable(update_table_request);
        }
        catch(Any e){
        	result = false;
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb.log");
        }
		return result;
	}
	
	public boolean function delete_table(required string table_name){
		var result = true;
		var delete_table_request = createObject("java","com.amazonaws.services.dynamodb.model.DeleteTableRequest").init().withTableName(trim(arguments.table_name));
        try{
        	variables.aws_dynamodb.deleteTable(delete_table_request);
        }
        catch(Any e){
        	result = false;
        	writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb.log");
        }
        return result;
	}
	
	public array function list_tables(string start_table, numeric limit=1){
		var table_request = createObject("java","com.amazonaws.services.dynamodb.model.ListTablesRequest").init();	
		table_request.setLimit(arguments.limit);
		if(structKeyExists(arguments,"start_table")){
			table_request.setExcusiveStartTableName(trim(arguments.start_table));
		}
		return variables.aws_dynamodb.listTables(table_request).getTableNames();
	}
	
	public any function put_item(required string table_name, required struct item){
		var put_item_request = createObject("java", "com.amazonaws.services.dynamodb.model.PutItemRequest").init(
			trim(arguments.table_name), 
			struct_to_dynamo_map(arguments.item)
		);
		return variables.aws_dynamodb.putItem(put_item_request);
	}
	
	public any function get_item(required string table_name, required string fields){
		var key = createObject("java", "com.amazonaws.services.dynamodb.model.Key").init().withHashKeyElement(new AttributeValue().withN("120"))
		var get_item_request = createObject(
			"java", "GetItemRequest"
		).init().withTableName(trim(arguments.table_name)).withKey().withAttributesToGet(trim(arguments.fields));
		result = client.getItem(getItemRequest);		
		// Check the response.
		System.out.println("Printing item after retrieving it....");
		printItem(result.getItem());            
	}
	
	private any function struct_to_dynamo_map(required struct cf_structure){
		var dynamo_map = createObject("java","java.util.HashMap").init();
		for( key in arguments.cf_structure ){
			if( isNumeric(arguments.cf_structure[key]) ){
				dynamo_map.put(
					"#key#", 
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withN("#arguments.cf_structure[key]#")
				);
			}
			else if( isArray(arguments.cf_structure[key]) ){
				dynamo_map.put(
					"#key#",
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withSS("#arrayToList(arguments.cf_structure[key])#")
				);
			}
			else{
				dynamo_map.put(
					"#key#",
					createObject("java","com.amazonaws.services.dynamodb.model.AttributeValue").init().withS("#arguments.cf_structure[key]#")
				);
			}
		}
		return dynamo_map;
	}
	
	/*
	 * I found the next three functions in various postings on the net and totally spaced on noting where set_timestamp was found. 
	 * I got HMAC_SHA256 and aws_signature from https://github.com/anujgakhar/AmazonSESCFC 
	 * If the original author of set_timestamp happens to see this, please let me know so that I may properly attribute it.
	 **/
	private any function aws_signature(required any signature_to_sign){
		var signature = "";
		var signature_data = replace(arguments.signature_to_sign,"\n","#chr(10)#","all");
		signature = toBase64( HMAC_SHA256(variables.aws_secret,signature_data) );		
		return signature;
	}
	
	private binary function HMAC_SHA256(required string sign_key, required string sign_message){
		var java_message = JavaCast("string",arguments.sign_message).getBytes("utf-8");
		var java_key = JavaCast("string",arguments.sign_key).getBytes("utf-8");
		var key = createObject("java","javax.crypto.spec.SecretKeySpec").init(java_key,"HmacSHA256");
		var mac = createObject("java","javax.crypto.Mac").getInstance(key.getAlgorithm());
		mac.init(key);
		mac.update(java_message);
		return mac.doFinal();
	}
	
	private any function set_timestamp(){
		var utc_date = dateAdd( "s", getTimeZoneInfo().utcTotalOffset, now() );
		var formatted_date = dateFormat( utc_date, "yyyy-mm-dd" ) & "T" & timeFormat( utc_date, "HH:mm:ss.l" ) & "Z";
		return formatted_date;
	}
}