/**
 * @accessors "false"
 * @alias "Application"
 * @bindingname ""
 * @displayname "Application"
 * @hint "I am the Application component"
 * @output "false"
*/
component {
	// application variables
	this.name = "cfdynamo";
	this.applicationtimeout = createTimeSpan(0,2,0,0);
	this.sessionmanagement = true;
	this.sessiontimeout = createTimeSpan(0,1,0,0);
	this.clientstorage = "cookie";
	this.clientmanagement = true;
	this.loginstorage = "session";
	this.enablerobustexception  = "true";
	this.securejson = true;
	this.securejsonprefix = "//";
	this.mappings["/cfdynamo"] = getDirectoryFromPath(getCurrentTemplatePath());

	// orm settings
	this.ormEnabled = false;

	/**
	 * @hint The application first starts: the first request for a page is processed or the first CFC method is invoked by an event gateway instance, or a web services or Flash Remoting CFC.
	 */
	public boolean function onApplicationStart(){
		application.aws = {};
		application.aws.credentials = xmlParse(expandPath("com/imageaid/cfdynamo/aws_credentials.xml"));
		application.aws.cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = application.aws.credentials.cfdynamo.access_key.xmlText, 
			aws_secret = application.aws.credentials.cfdynamo.secret_key.xmlText
		);		
		return true;
	}

	/**
	 * @hint The application ends: the application times out, or the server is stopped
	 */
	public void function onApplicationEnd(ApplicationScope){

	}

	/**
	 * @hint The onRequestStart method finishes. (This method can filter request contents.)
	 */
	public void function onRequest(String targetPage){
		include arguments.targetPage;
	}

	/**
	 * @hint A request starts
	 */
	public boolean function onRequestStart(String targetPage){

		return true;
	}

	/**
	 * @hint All pages in the request have been processed:
	 */
	public void function onRequestEnd(String targetPage){

	}

	/**
	 * @hint A session starts
	 */
	public void function onSessionStart(){

	}

	/**
	 * @hint A session ends
	 */
	public void function onSessionEnd(SessionScope,ApplicationScope){

	}

	/**
	 * @hint ColdFusion received a request for a non-existent page.
	 */
	public boolean function onMissingTemplate(String targetPage) {

		return true;
	}

	/**
	 * @hint An exception that is not caught by a try/catch block occurs.
	 */
	public void function onError(Exception,EventName) {

	}

	/**
	 * @hint Handles missing method exceptions
	 */
	public void function onMissingMethod(String method,Struct args) {

	}

	/**
	 * @hint HTTP or AMF calls are made to an application.
	 */
	public void function onCFCRequest(String cfcname,String method,Struct args){

	}
}
