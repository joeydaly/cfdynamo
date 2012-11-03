component extends="mxunit.framework.TestCase" name="DynamoDBTest" displayName="DynamoDBTest" hint="I test the various DynamoDB interactions"{
	
	public void function setUp(){
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