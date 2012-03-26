component extends="mxunit.framework.TestCase" name="DynamoDBTest" displayName="DynamoDBTest" hint="I test the various DynamoDB interactions"{
	
	public void function setUp(){
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		obj = new cfdynamo.com.imageaid.cfdynamo.DynamoClient(aws_key = credentials.cfdynamo.access_key.xmlText,aws_secret = credentials.cfdynamo.secret_key.xmlText);
	}
	
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
	
}