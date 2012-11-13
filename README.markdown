# CFDynamo #

CFDynamo is a typically lame-named ColdFusion wrapper for the Amazon DynamoDB Java API.

## Goal ##
To build a simple but effective CFC wrapper for the Java AWS SDK for DynamoDB.

## Setup ##
Setup is faily simple, with the only real consideration being the implementation for the Java AWS SDK on your Railo/ACF instance. 

To make this process as easy to follow as possible, here are a set of instructions that will get you up and running from _nothing_. 

### Get & Install Apache Tomcat ###
Skip this section if you already have Tomcat running and you're happy with your life and your J2EE container. :)

1. Download the latest [Apache Tomcat](http://tomcat.apache.org/download-70.cgi) - choose the Core zip file.
1. Unpack the contents of the zip file anywhere you like to run Tomcat from.
1. Set some environment variables for Tomcat that help ColdFusion run well.  One approach to this is to create a *setenv.sh* file in the tomcat/bin folder. Immediately below is a sample set of commands you could use that work well with Adobe ColdFusion or Railo.
1. Start Tomcat by executing the startup.sh or startup.bat (depending on platform)
1. Make sure it's up and running by [browsing to the local host](http://127.0.0.1:8080).

#### Sample setenv.sh / setenv.bat Commands ####
<pre><code>
export CATALINA_OPTS="$CATALINA_OPTS -Xms2048m"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx2048m"
export CATALINA_OPTS="$CATALINA_OPTS -Xss256k"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=256m"

echo "Using CATALINA_OPTS:"
for arg in $CATALINA_OPTS
do
    echo ">> " $arg
done
echo ""
</code></pre>

### Get & Install CFML Engine ###
Skip this section if you already have your favorite CFML engine installed and happily responding to requests in your J2EE container! :)
 
We're not going to cover which flavor you use here, the following instructions should be generic enough to work on Railo, Adobe ColdFusion, etc.  The following directions cover the J2EE installation of the CFML engine. If you choose to use the stand-alone installation options for those products you are on your own to adapt these instructions.

1. Obtain the J2EE Web Archive (.WAR file) that contains your CFML engine.
1. Unpack the WAR file into its directory structures in a place you want to develop and/or test in. Whatever folder this happens to be, that's the path that will be used below in the example XML for "/path/to/where/you/will/unpack/CFML/engine"
1. Stop Tomcat if it's currently running.
1. Modify your operating system's *HOSTS* file, adding the following line so we can refer to the standalone cfdynamo site

	127.0.0.1	cfdynamo.local

1. Modify Tomcat's *server.xml* file, which is located in the <code>tomcat/conf</code> folder.  Add the following *Host* entry:

	<Host name="cfdynamo.local" appBase="webapps" unpackWARs="false" autodeploy="true">
		<Alias>cfdynamo.local</Alias>
		<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="cfdynamo_access" suffix=".log" />
		<Context path="" docBase="/path/to/where/you/will/unpack/CFML/engine" />
	</Host>

1. Start Tomcat. Watch the catalina.out log to make sure no errors are thrown during startup.


### Download and install the AWS Java SDK ###
The cfdynamo connector library makes use of Amazon's Java SDK.  It's essentially a wrapper for it.  However, the SDK is not a part of this project.
Therefore, as a separate step make sure you've obtained and installed the SDK into your web application's class path.  There are two places you can
put it.  One place would be where all applications deployed in the Tomcat container can see it.  The other is in the application itself, which is
preferred (and outlined in the following steps) only for it's specificity.

1. Download the latest version of the [AWS Java SDK](http://aws.amazon.com/sdkforjava/)
1. Expand the AWS Java SDK zip archive and find the main JAR file (e.g. "aws-java-sdk-1.3.22.jar" - version numbers could be different if I'm talking to a person in the future)
1. Copy or move the AWS SDK JAR to your web application's WEB-INF/lib folder, which should already be in Tomcat's JVM class path. NOTE: If you want to make the lib available to all the applications in your container, place it in the Tomcat-ROOT/lib folder.
1. Restart Tomcat, which will pull in the AWS SDK.


### Setup the cfdynamo library ###
Follow these steps to get the library working and the tests functional.  You can start your efforts here if
you already have a running CFML engine and a webroot to drop cfdynamo into.

1. Expand the cfdynamo zip archive from Github into the docBase noted above, or wherever you prefer to drop this library in.
1. Point your web browser to http://cfdynamo.local:8080/ (assuming Tomcat is setup to run on the default port 8080) and you should see a short list of choices, including running the tests or viewing the samples.


### Configure Credentials ###
Amazon Web Services doesn't just let any Joe off the street access DynamoDB!  You need to provide your account credentials.
Note that this is not a very secure place to put this XML file.  Feel free to change where it lives.  The important part
is that the values are passed to the DynamoDBClient.cfc's init method.  How the credentials are stored and where is your choice.
One approach, which is far more protected, is to make them Java system properties.
1. Rename /aws_credentials_template.xml to /aws_credentials.xml
1. Enter your access key
1. Enter your secret key
1. Save the file

*You're setup and ready to go!*
  

## Sample Application & Code ##
To help you get started there is a sample application and code in the /samples/index.cfm part of the application.  Hopefully this will get you started on the right foot quickly with the
cfdynamo connector library.