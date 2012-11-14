/**
 * @hint "Sample application within which the cfdynamo connector could live and power data persistence to the AWS cloud."
 * @output "false"
*/
component {


	// application variables
	this.name = "cfdynamo-sample-application";
	this.applicationTimout = createTimeSpan(0, 2, 0, 0);
	this.sessionmanagement = false;
	this.enablerobustexception  = "true";
	this.mappings["/mxunit"] = expandPath("/mxunit");
	this.mappings["/com"] = expandPath("/com");

	// orm settings
	this.ormEnabled = false;


	/**
	 * @hint The application first starts: the first request for a page is processed or the first CFC method is invoked by an event gateway instance, or a web services or Flash Remoting CFC.
	 */
	public boolean function onApplicationStart() {
		application.aws = {};
		var credentials = xmlParse(expandPath("/aws_credentials.xml"));
		application.aws.cfdynamo = new com.imageaid.cfdynamo.DynamoDBClient(
			awsKey = credentials.cfdynamo.access_key.xmlText,
			awsSecret = credentials.cfdynamo.secret_key.xmlText
		);
		return true;
	}


	public Boolean function onRequestStart() {
		if (structKeyExists(url, "runApplicationStart")) {
			onApplicationStart();
			writeOutput("Ran onApplicationStart.");
			abort;
		}
		return true;
	}


}