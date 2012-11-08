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
1. Set some environment variables for Tomcat that help ColdFusion run well.  One approach to this is to create a *setenv.sh* file in the tomcat/bin folder. Here is a sample set of commands you could use that work well with Adobe ColdFusion or Railo:
```
# Nothing to set at this time.
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
```
1. Start Tomcat by executing the startup.sh or startup.bat (depending on platform)
1. Make sure it's up and running by [browsing to the local host](http://127.0.0.1:8080).

### Get & Install CFML Engine ###
Skip this section if you already have your favorite CFML engine installed and happily responding to requests in your J2EE container! :)
 
We're not going to cover which flavor you use here, the following instructions should be generic enough to work on Railo, Adobe ColdFusion, etc.  The following directions cover the J2EE installation of the CFML engine. If you choose to use the stand-alone installation options for those products you are on your own to adapt these instructions.

1. Obtain the J2EE Web Archive (.WAR file) that contains your CFML engine.
1. Unpack the WAR file into its directory structures in a place you want to develop and/or test in.
1. Stop Tomcat if it's currently running.
1. Modify your operating system's *HOSTS* file, adding the line <pre>
127.0.0.1	cfdynamo.local</pre>
1. Modify Tomcat's *server.xml* file, which is located in the tomcat/conf folder.  Add the following *Host* entry:
```xml
<Host name="cfdynamo.local" appBase="webapps" unpackWARs="false" autodeploy="true">
		<Alias>cfdynamo.local</Alias>
		<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="cfdynamo_access" suffix=".log" />
		<Context path="" docBase="/path/to/where/you/unpacked/CFML/engine" />
</Host>
```

1. Download/expand the Zip archive from Github.
1. Rename the downloaded folder to *cfdynamo*
1. Add the *cfdynamo* folder and its contents to your web application or web root (you can remove the samples and other files, not in the com folder, if you like)
1. Download the latest version of the [AWS Java SDK](http://aws.amazon.com/sdkforjava/)
1. Expand the AWS Java SDK and find the main JAR file (e.g. "aws-java-sdk-1.3.22.jar" - version numbers could be different if I'm talking to a person in the future)
1. Copy or move the AWS SDK JAR to your web application's WEB-INF/lib folder, which should already be in Tomcat's JVM classpath. NOTE: If you want to make the lib available to all the applications in your container, place it in the Tomcat-ROOT/lib folder.
1. Restart Tomcat, which will pull in the AWS SDK.
  

If you use Adobe ColdFusion 9, the general idea is the same but here is how I configured ACF9 (stand-alone server) to load my AWS JARs: 

1. Download/expand the Zip archive from Github.
2. Rename the downloaded folder to cfdynamo
3. Inside the assets folder is a Zip archive containing the AWS and related JARs ... expand this archive (the expanded archive will be named "aws")
4. Move the newly expanded "aws" folder^ into your {Adobe ColdFusion 9 Install Folder}/WEB-INF/lib folder.
5. Open {Adobe ColdFusion 9 Install Folder}/runtime/bin/jvm.config and find the line with "java.class.path=" (there may be a better way to do this but this is how I got it working with the lest amount of headaches)
6. Add the following to the end of the java.class.path= line: ,{application.home}/../wwwroot/WEB-INF/lib/aws
7. Add the "cfdynamo" folder and its content to your web application (you can remove the examples and other files if you like)
8. Add a mapping to "cfdynamo" in your web administrator ... the sample app attemtps to create a /cfdynamo mapping for you, but, if you're going to use this in an application, it's probably best to just add the mapping the the administrator.
9. Retart ACF 9

### Sample App ###
Other than the assets folder in this Git repository, which you need to address with the steps above, you can clone the files into a directory in your web root and just get going. Sort of ... you still have to create a table in the AWS console (going to add the createTable wrapper shortly).

^The "aws" folder contains a series of JARs. These JARs can be dropped directly into your {tomcat root}/lib or {Adobe ColdFusion 9 Install Folder}/wwwroot/WEB-INF/lib/ folder with no updates to the catalina.properties file. 

However, I prefer to keep my added JARs organized into their own folders for easier updates, etc. Hence, the use of the "aws" folder to hold all of these JARs.

### Details to Come ###
More details to come on the project ... just getting the initial repo setup today. 