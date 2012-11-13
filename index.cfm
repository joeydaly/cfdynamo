<h1>You're running the CFDynamo Amazon AWS DynamoDB connector sample application.</h1>
<p>
	Thanks for trying it out!  Here's a dump of your instance in the applicatin scope
	that you can start using at any time, assuming you've filling in your AWS credentials.
</p>
<cfdump var="#application.aws.cfdynamo#" expand="false" label="cfdynamo connector lib" />
<ul>
	<li><a href="samples/">Samples</a></li>
	<li>
		<a href="com/imageaid/cfdynamo/tests/cfDynamoTestSuite.cfm">Run All Tests</a>
		<ul>
			<li><a href="com/imageaid/cfdynamo/tests/dynamodb/DynamoDBClientUnitTest.cfc?method=runtestremote&output=html">Run Unit Tests</li>
			<li><a href="com/imageaid/cfdynamo/tests/dynamodb/DynamoDBClientIntegrationTest.cfc?method=runtestremote&output=html">Run Integration Tests</a>
		</ul>
	</li>
</ul>