<cfscript>
	test_suite = new mxunit.framework.TestSuite().TestSuite();
	test_suite.addAll("com.imageaid.cfdynamo.tests.dynamodb.DynamoDBClientUnitTest");
	test_suite.addAll("com.imageaid.cfdynamo.tests.dynamodb.DynamoDBClientIntegrationTest");

	results = test_suite.run();
	writeOutput( results.getResultsOutput('html') );
</cfscript>